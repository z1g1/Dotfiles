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
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
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
    """Parse a github.com blob URL or raw.githubusercontent.com URL.

    Returns {owner, repo, ref, path}. Raises ValueError on unsupported forms.
    """
    blob = re.match(
        r"https?://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$", url)
    if blob:
        owner, repo, ref, path = blob.groups()
        return {"owner": owner, "repo": repo, "ref": ref, "path": path}

    raw = re.match(
        r"https?://raw\.githubusercontent\.com/([^/]+)/([^/]+)/([^/]+)/(.+)$",
        url)
    if raw:
        owner, repo, ref, path = raw.groups()
        return {"owner": owner, "repo": repo, "ref": ref, "path": path}

    if re.match(r"https?://github\.com/[^/]+/[^/]+/tree/", url):
        raise ValueError(
            "that is a directory (tree) URL — point at the specific SKILL.md "
            "blob URL instead")

    raise ValueError(
        "unsupported URL; expected a github.com '/blob/<ref>/<path>' or "
        "raw.githubusercontent.com URL")


# --- HTTP / GitHub API -------------------------------------------------------

def _request(url: str, accept: str = "application/vnd.github+json") -> bytes:
    headers = {
        "User-Agent": "dotfiles-skill-tool",
        "Accept": accept,
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read()


def gh_api(path: str) -> object:
    return json.loads(_request(f"https://api.github.com{path}"))


def latest_commit_for_path(owner: str, repo: str, ref: str, path: str):
    """Return the most recent commit SHA touching `path` on `ref`, or None."""
    enc = urllib.parse.quote(path)
    data = gh_api(
        f"/repos/{owner}/{repo}/commits?sha={ref}&path={enc}&per_page=1")
    if isinstance(data, list) and data:
        return data[0]["sha"]
    return None


def repo_license(owner: str, repo: str) -> str:
    try:
        data = gh_api(f"/repos/{owner}/{repo}/license")
        spdx = (data.get("license") or {}).get("spdx_id")
        return spdx or "UNKNOWN"
    except urllib.error.HTTPError:
        return "UNKNOWN"


def raw_url(owner: str, repo: str, sha: str, path: str) -> str:
    return f"https://raw.githubusercontent.com/{owner}/{repo}/{sha}/{path}"


def fetch_raw(owner: str, repo: str, sha: str, path: str) -> bytes:
    return _request(raw_url(owner, repo, sha, path), accept="*/*")


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
