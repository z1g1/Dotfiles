---
name: project-scaffold
description: >-
  Bootstrap or augment TypeScript monorepo projects with pnpm workspaces, Docker
  (multi-stage builds, compose for dev), GitHub Actions CI/CD, BiomeJS, and
  Husky pre-commit hooks. Use when starting a new project, creating a monorepo,
  bootstrapping an app, setting up project infrastructure, or implementing
  Feature 0 / foundation tasks that need repository setup, linting, formatting,
  CI pipelines, git hooks, or containerization. Safe for both greenfield and
  brownfield — checks for existing files before writing.
# --- vendored-provenance (managed by bin/skill-add) ---
source: https://github.com/ncharris93/ai-docs
source_path: skills/project-scaffold/SKILL.md
source_commit: 18c8c8a554b374395cc574faf44c8b9d8ead7f15
license: UNKNOWN
vendored: 2026-06-03
# --- end vendored-provenance ---
---

# Project Scaffold

Bootstrap a TypeScript monorepo with standardized infrastructure.

## Stack Defaults

| Component | Default |
|-----------|---------|
| Package manager | pnpm workspaces |
| Build system | Turborepo |
| Node version | 24 LTS (Alpine) |
| Linting/formatting | BiomeJS |
| Git hooks | Husky with pre-commit formatting |
| Containerization | Docker multi-stage + Compose for dev (see `docker-best-practices` skill) |
| CI/CD | GitHub Actions (CI on PR, deploy on main) |

## Brownfield Safety

Before writing any file, check if it already exists. Group checks by functional area and present findings to the user:

**Functional areas to check:**

| Area | Files to check |
|------|---------------|
| Package manager | `pnpm-workspace.yaml`, `package.json` (root) |
| Build system | `turbo.json` |
| Linting/formatting | `biome.json`, `.eslintrc*`, `.prettierrc*` |
| Git hooks | `.husky/` |
| Containerization | `Dockerfile`, `docker-compose.yml` |
| CI/CD | `.github/workflows/ci.yml` |
| TypeScript config | `tsconfig.base.json`, `tsconfig.json` |
| Git ignore | `.gitignore` |

**For each area where files already exist**, ask the user:
- **Skip**: Keep existing files as-is
- **Overwrite**: Replace with scaffold templates
- **Merge**: Manually review and merge (show diff of template vs existing)

**If no existing files are found in any area**, proceed as greenfield (no prompts needed).

## Package Structure

```
project-root/
  packages/
    api/                    # API with domain-based organization
      src/
        domains/
          user/             # routes, services, repositories, entities
          billing/
          ...
        shared/             # Cross-domain (middleware, errors, etc.)
        index.ts            # App entry point
    web/                    # Frontend application
    shared/                 # Shared types/utils (cross-package)
  docker-compose.yml        # Dev environment with hot reload
  Dockerfile                # Multi-stage production build
  .husky/
    pre-commit              # Pre-commit hook: biome format
  pnpm-workspace.yaml
  turbo.json                # Turborepo pipeline config
  biome.json
  tsconfig.base.json
  .github/workflows/ci.yml
```

## Workflow

1. **Gather requirements**
   - Project name (used for package naming, docker image)
   - Which packages needed initially (api, web, shared)
   - Any services needed (postgres, redis, etc.)
   - Initial domains for api package

2. **Detect existing infrastructure**
   - For each functional area (see Brownfield Safety), check if files exist
   - If ANY files exist: present a summary table showing what exists vs what the scaffold would add
   - Ask user per-area: skip / overwrite / merge
   - Record decisions for Step 3

3. **Copy and customize assets**
   - For greenfield areas (nothing exists): copy templates, replace `{{PROJECT_NAME}}` placeholders
   - For overwrite areas: copy templates, replace placeholders (overwrites existing)
   - For merge areas: show diff between template and existing file, let user decide line-by-line
   - For skip areas: do nothing
   - Adjust docker-compose services based on requirements

4. **Create package scaffolds**
   - Each package gets: `package.json`, `tsconfig.json`, `src/index.ts`
   - API package gets: `.env.example`, domain folder structure
   - Web package gets: `.env.example`

5. **Initialize**
   - `pnpm install` (always — safe to re-run)
   - `pnpm exec husky init` (only if `.husky/` was created/overwritten in this run)
   - `git init` (only if `.git/` does not exist)

## Assets

| File | Purpose |
|------|---------|
| `assets/pnpm-workspace.yaml` | Workspace configuration |
| `assets/turbo.json` | Turborepo pipeline configuration |
| `assets/package.json` | Root package.json template (includes husky dependency) |
| `assets/tsconfig.base.json` | Shared TypeScript config |
| `assets/biome.json` | Linting and formatting rules |
| `assets/.husky/pre-commit` | Pre-commit hook that runs biome format |
| `assets/Dockerfile` | Multi-stage production build |
| `assets/docker-compose.yml` | Dev environment with hot reload |
| `assets/.github/workflows/ci.yml` | CI/CD pipeline |
| `assets/.gitignore` | Standard ignores |

## Docker Best Practices

Generated Docker artifacts follow the `docker-best-practices` skill:

- **docker-compose.yml**: Development environment with 0.0.0.0 port bindings for external inspection, volume mounts for hot reload
- **Dockerfile**: Production builds for API packages (multi-stage, optimized)
- **Web packages**: Built to static bundles for CDN, not containerized

Refer to the `docker-best-practices` skill for detailed patterns:
- `dev-compose-binding-0-0-0-0` - Why services bind to 0.0.0.0
- `dev-vs-prod-distinction` - Why docker-compose is dev-only; Dockerfile is prod-only
- `image-output-api-services` - API packages as Docker images
- `image-output-web-bundles` - Web packages as static bundles

## References

- `references/package-templates.md` - Package-level scaffolding patterns
