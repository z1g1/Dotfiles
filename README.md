# Customizations Monorepo

A single repo for everything I want on a machine: shell/editor dotfiles, my
Claude Code harness (settings, global guidance, hooks, agents, slash commands),
my own skills, and **vendored third-party skills** tracked for provenance and
upstream drift.

## Layout

```
.
├── setup.sh                 # one-step machine setup (backup + symlink)
├── bin/
│   ├── skill-add            # vendor / update a third-party skill
│   ├── skill-check          # report upstream drift for vendored skills
│   └── skilllib.py          # shared helpers (stdlib only)
├── dotfiles/                # .zshrc .tmux.conf .vimrc .bashrc + hardware layouts
│   └── README.md            # tmux workspace docs, color reference, helper fns
└── claude/
    ├── settings.json        # user-wide Claude Code settings  -> ~/.claude/settings.json
    ├── CLAUDE.md            # global guidance                 -> ~/.claude/CLAUDE.md
    ├── hooks/               # ntfy notification hooks          -> ~/.claude/hooks/
    ├── scripts/             # macOS notify helper
    ├── prompts/             # imported (git subtree) — agents/ + commands/ + docs
    └── skills/
        ├── mine/            # skills I author (my harness, grown over time)
        ├── vendored/        # third-party skills, one folder each
        │   └── <name>/
        │       ├── SKILL.md          # working copy (mine to edit)
        │       └── .upstream/SKILL.md# pristine, byte-exact upstream snapshot
        └── skills.lock.toml # provenance + version lockfile (source of truth)
```

## Setup on a new machine

```bash
git clone https://github.com/z1g1/Dotfiles.git ~/projects/customizations
cd ~/projects/customizations
./setup.sh
```

`setup.sh` is OS-aware (apt/yum/dnf/pacman/brew), backs up anything it would
overwrite to `~/.dotfiles_backup_<timestamp>`, then symlinks:

| Target | Source |
|---|---|
| `~/.zshrc` `~/.tmux.conf` `~/.vimrc` `~/.bashrc` | `dotfiles/*` |
| `~/.claude/settings.json` | `claude/settings.json` |
| `~/.claude/CLAUDE.md` | `claude/CLAUDE.md` |
| `~/.claude/hooks/*.sh` | `claude/hooks/*.sh` |
| `~/.claude/agents` `~/.claude/commands` | `claude/prompts/{agents,commands}` |
| `~/.claude/skills/<name>` | each folder in `claude/skills/{mine,vendored}/` |

Because everything is symlinked, editing a file in the repo takes effect
immediately — no re-run needed (re-run only after adding a **new** skill folder).

> Secrets are never committed. Copy `claude/.secrets.example` to
> `~/.claude/.secrets` and fill in `NTFY_TOKEN` per host; hooks no-op until then.

## Vendoring a third-party skill

> **Requires the GitHub CLI.** All network access goes through `gh api`, using
> your authenticated `gh` session — so this works with **private** repositories
> you have access to, and uses the authenticated rate limit (5000/hr). Install
> `gh` from <https://cli.github.com> and run `gh auth login` (grant the `repo`
> scope for private repos) once per machine.

Point `skill-add` at the skill's `SKILL.md` blob URL on GitHub:

```bash
bin/skill-add \
  "https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md" \
  --notes "why I grabbed this / what idea it gave me"
```

This pins the latest commit touching that file, downloads it to
`vendored/<name>/.upstream/SKILL.md` (pristine), writes a working copy with a
provenance block injected into its frontmatter, and records source + commit +
sha256 + license + date in `skills.lock.toml`. Only the single file is vendored —
no submodules, no external history dragged in. Run `setup.sh` afterward to link
the new skill into `~/.claude/skills/`.

### Vendoring a whole folder at once

Point `skill-add` at a `/tree/` **directory** URL to vendor every `SKILL.md`
found under it in one pass (one Git Trees API call, any depth):

```bash
bin/skill-add "https://github.com/mattpocock/skills/tree/main/skills/engineering"
```

Skills already in the lockfile are skipped (use `--update` to refresh them), so a
re-run never clobbers your local edits or notes. A per-skill download failure
warns and skips rather than aborting the batch, and progress is saved after each.

Note each vendored file is pinned to the latest commit that touched *it*, so
skills from the same folder can legitimately show different commit SHAs.

## Checking for upstream drift

```bash
bin/skill-check
```

For each vendored skill it re-fetches upstream and reports **SAME / CHANGED /
GONE**, flags whether you've **locally modified** the working copy, and for
CHANGED prints a unified diff plus a GitHub compare URL. Exit code is non-zero if
anything changed — handy in a cron/CI check. To accept an update:

```bash
bin/skill-add --update <name>      # one skill
bin/skill-add --update --all       # every locked skill
```

If you'd edited the working copy (`modified = true` in the lockfile), the update
refreshes `.upstream/` but leaves your copy alone so you can re-merge against the
pristine baseline. Drift is always measured *upstream-now vs the pristine
snapshot*, so it is independent of your local edits.

## Updating the imported prompts (git subtree)

`claude/prompts/` is a git subtree of the standalone prompts repo. To pull
upstream changes (if that repo is still maintained):

```bash
git subtree pull --prefix=claude/prompts prompts main
```

## Dotfiles details

See [`dotfiles/README.md`](dotfiles/README.md) for tmux workspace setup, pane
color reference, and the `tp()` / `tmux-init()` helper functions.
