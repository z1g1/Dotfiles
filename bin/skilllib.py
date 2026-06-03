"""Shared helpers for the vendored-skill tooling (skill-add / skill-check).

Zero third-party dependencies: stdlib only. Reads TOML with tomllib (Py3.11+)
and serializes TOML by hand (stdlib has no writer) for the flat lockfile schema.

Provenance + drift model:
  claude/skills/vendored/<name>/
    SKILL.md            working copy (yours to edit; carries provenance frontmatter)
    .upstream/SKILL.md  pristine, byte-exact upstream snapshot (drift baseline)
  claude/skills/skills.lock.toml   source of truth: where it came from + version

Drift is measured upstream-now vs pristine (.upstream), so it is independent of
any local edits you make to the working copy.
"""

from __future__ import annotations

import datetime
import hashlib
import json
import re
import shutil
import subprocess
import sys
import urllib.parse
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - we require 3.11+
    sys.exit("error: Python 3.11+ with tomllib is required")

# --- repo layout -------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "claude" / "skills"
VENDORED_DIR = SKILLS_DIR / "vendored"
LOCKFILE = SKILLS_DIR / "skills.lock.toml"

PROV_BEGIN = "# --- vendored-provenance (managed by bin/skill-add) ---"
PROV_END = "# --- end vendored-provenance ---"


# --- small output helpers ----------------------------------------------------

def info(msg: str) -> None:
    print(msg)


def warn(msg: str) -> None:
    print(f"warning: {msg}", file=sys.stderr)


def die(msg: str) -> None:
    sys.exit(f"error: {msg}")


# --- GitHub URL parsing ------------------------------------------------------

def parse_github_url(url: str) -> dict:
    """Parse a github.com blob/tree URL or raw.githubusercontent.com URL.

    Returns {kind, owner, repo, ref, path} where kind is 'blob' (a single
    SKILL.md) or 'tree' (a directory to vendor every SKILL.md from).
    Raises ValueError on unsupported forms.
    """
    blob = re.match(
        r"https?://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$", url)
    if blob:
        owner, repo, ref, path = blob.groups()
        return {"kind": "blob", "owner": owner, "repo": repo,
                "ref": ref, "path": path}

    raw = re.match(
        r"https?://raw\.githubusercontent\.com/([^/]+)/([^/]+)/([^/]+)/(.+)$",
        url)
    if raw:
        owner, repo, ref, path = raw.groups()
        return {"kind": "blob", "owner": owner, "repo": repo,
                "ref": ref, "path": path}

    tree = re.match(
        r"https?://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$", url)
    if tree:
        owner, repo, ref, path = tree.groups()
        return {"kind": "tree", "owner": owner, "repo": repo,
                "ref": ref, "path": path.rstrip("/")}

    raise ValueError(
        "unsupported URL; expected a github.com '/blob/<ref>/<path>', "
        "'/tree/<ref>/<dir>', or raw.githubusercontent.com URL")


def git_tree_skill_paths(owner: str, repo: str, ref: str, dir_path: str):
    """Find every SKILL.md path under `dir_path` in one Git Trees API call.

    Returns (sorted_paths, truncated). `truncated` is True if GitHub capped the
    tree response (very large repos) — callers should warn that some skills may
    be missing. Matches SKILL.md at any depth below the directory.
    """
    enc_ref = urllib.parse.quote(ref, safe="")
    data = gh_api(f"/repos/{owner}/{repo}/git/trees/{enc_ref}?recursive=1")
    prefix = dir_path.rstrip("/") + "/"
    out = []
    for item in data.get("tree", []):
        if item.get("type") != "blob":
            continue
        p = item["path"]
        if not p.startswith(prefix):
            continue
        if p.rsplit("/", 1)[-1].lower() == "skill.md":
            out.append(p)
    return sorted(out), bool(data.get("truncated"))


# --- GitHub access via the `gh` CLI ------------------------------------------
# All network access goes through `gh api`, which uses the user's authenticated
# gh session. That transparently grants access to PRIVATE repositories and
# raises the rate limit to the authenticated tier (5000/hr).

class GHError(Exception):
    """A `gh api` call failed. `.status` is the HTTP status code if parseable."""

    def __init__(self, message: str, status: int | None = None):
        super().__init__(message)
        self.status = status


_GH_READY = False


def ensure_gh() -> None:
    """Verify `gh` is installed and authenticated (checked once per process)."""
    global _GH_READY
    if _GH_READY:
        return
    if shutil.which("gh") is None:
        die("GitHub CLI 'gh' not found on PATH. Install it from "
            "https://cli.github.com and run 'gh auth login'.")
    proc = subprocess.run(["gh", "auth", "status"],
                          capture_output=True, text=True)
    if proc.returncode != 0:
        die("GitHub CLI is not authenticated. Run 'gh auth login' "
            "(grant the 'repo' scope to read private repositories).")
    _GH_READY = True


def _gh_api_raw(endpoint: str, accept: str | None = None) -> bytes:
    """Run `gh api <endpoint>` and return the raw response body as bytes.

    Raises GHError (with .status set when the HTTP code is detectable) on
    failure — e.g. 404 (missing repo/path) or 403 (no access / rate limit).
    """
    ensure_gh()
    cmd = ["gh", "api"]
    if accept:
        cmd += ["-H", f"Accept: {accept}"]
    cmd.append(endpoint)
    proc = subprocess.run(cmd, capture_output=True)
    if proc.returncode != 0:
        stderr = proc.stderr.decode("utf-8", errors="replace").strip()
        m = re.search(r"HTTP (\d{3})", stderr)
        raise GHError(stderr or f"gh api {endpoint} failed",
                      status=int(m.group(1)) if m else None)
    return proc.stdout


def gh_api(path: str) -> object:
    """GET a GitHub REST endpoint via gh and return parsed JSON.

    Accepts a leading '/' for backwards compatibility with prior callers.
    """
    return json.loads(_gh_api_raw(path.lstrip("/")))


def latest_commit_for_path(owner: str, repo: str, ref: str, path: str):
    """Return the most recent commit SHA touching `path` on `ref`, or None."""
    enc_path = urllib.parse.quote(path)
    enc_ref = urllib.parse.quote(ref, safe="")
    data = gh_api(
        f"repos/{owner}/{repo}/commits"
        f"?sha={enc_ref}&path={enc_path}&per_page=1")
    if isinstance(data, list) and data:
        return data[0]["sha"]
    return None


def repo_license(owner: str, repo: str) -> str:
    try:
        data = gh_api(f"repos/{owner}/{repo}/license")
    except GHError:
        return "UNKNOWN"
    spdx = (data.get("license") or {}).get("spdx_id")
    return spdx or "UNKNOWN"


def raw_url(owner: str, repo: str, sha: str, path: str) -> str:
    """Informational pinned-content URL recorded in the lockfile.

    Note: for private repos this URL needs auth to open directly; the tooling
    itself fetches content through `gh api` (see fetch_raw), not this URL.
    """
    return f"https://raw.githubusercontent.com/{owner}/{repo}/{sha}/{path}"


def fetch_raw(owner: str, repo: str, sha: str, path: str) -> bytes:
    """Download a file's exact bytes at `sha` via the authenticated gh session.

    Uses the contents API with the raw media type so it works for private repos.
    """
    enc_path = urllib.parse.quote(path)
    return _gh_api_raw(
        f"repos/{owner}/{repo}/contents/{enc_path}?ref={sha}",
        accept="application/vnd.github.raw")


def compare_url(owner: str, repo: str, old: str, new: str) -> str:
    return f"https://github.com/{owner}/{repo}/compare/{old}...{new}"


# --- hashing / naming --------------------------------------------------------

def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def skill_name_from_path(path: str) -> str:
    p = Path(path)
    if p.name.lower() == "skill.md":
        return p.parent.name or p.stem
    return p.stem


# --- provenance frontmatter --------------------------------------------------

def provenance_block(meta: dict) -> str:
    return "\n".join([
        PROV_BEGIN,
        f"source: {meta['source']}",
        f"source_path: {meta['path']}",
        f"source_commit: {meta['commit']}",
        f"license: {meta['license']}",
        f"vendored: {meta['vendored_on']}",
        PROV_END,
    ])


def with_provenance(text: str, meta: dict) -> str:
    """Return `text` with a provenance block inside its YAML frontmatter.

    If the file opens with a `---` frontmatter fence, insert the block just
    before the closing fence. Otherwise, wrap the body in a fresh frontmatter
    fence containing the block.
    """
    block = provenance_block(meta)
    lines = text.splitlines()
    if lines and lines[0].strip() == "---":
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                new_lines = lines[:i] + block.split("\n") + lines[i:]
                return "\n".join(new_lines) + ("\n" if text.endswith("\n") else "")
        # malformed frontmatter (no close) — fall through to wrap
    fenced = ["---"] + block.split("\n") + ["---", ""]
    return "\n".join(fenced) + text


# --- lockfile read/write -----------------------------------------------------

def read_lock() -> dict:
    if not LOCKFILE.exists():
        return {"skills": {}}
    with LOCKFILE.open("rb") as fh:
        data = tomllib.load(fh)
    data.setdefault("skills", {})
    return data


def _toml_str(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


_FIELD_ORDER = [
    "source", "ref", "path", "raw_url", "commit",
    "sha256", "license", "vendored_on", "modified", "notes",
]


def write_lock(data: dict) -> None:
    out = [
        "# Vendored third-party skills — provenance + version lockfile.",
        "# Managed by bin/skill-add and inspected by bin/skill-check.",
        "# Drift = upstream-now vs the pristine .upstream/ snapshot (sha256 below).",
        "",
    ]
    for name in sorted(data.get("skills", {})):
        entry = data["skills"][name]
        out.append(f"[skills.{name}]")
        for field in _FIELD_ORDER:
            if field not in entry:
                continue
            val = entry[field]
            if isinstance(val, bool):
                out.append(f"{field} = {'true' if val else 'false'}")
            else:
                out.append(f"{field} = {_toml_str(str(val))}")
        out.append("")
    LOCKFILE.parent.mkdir(parents=True, exist_ok=True)
    LOCKFILE.write_text("\n".join(out))


def today() -> str:
    return datetime.date.today().isoformat()
