# Development Preferences & Guidelines

This document defines development practices, technology selection criteria, and workflow requirements that Claude Code must follow when working on projects.

## Technology Selection Principles

### Stability & Support Requirements

**CRITICAL**: Always prefer stable, well-supported, and widely-adopted technologies.

1. **Avoid Experimental/Beta Software**
   - Do NOT use experimental features, beta releases, or alpha versions
   - Do NOT use "nightly" builds or pre-release versions
   - Only use software marked as stable and production-ready
   - If only beta/experimental options exist, STOP and ask the user for approval

2. **Prefer Established Libraries**
   - Choose libraries with:
     - Active maintenance and regular updates
     - Large user base and community support
     - Comprehensive documentation
     - Proven track record in production
     - Long-term support (LTS) versions when available

3. **Version Selection**
   - Use latest **stable** version, not latest release
   - Check for LTS (Long Term Support) versions
   - Avoid bleeding-edge versions unless user explicitly requests
   - Example: Python 3.12 (stable) not Python 3.13-rc (release candidate)

4. **Check Before Adding Dependencies**
   - Research library maturity before recommending
   - Verify active maintenance (recent commits, releases)
   - Check for known security vulnerabilities
   - Consider bundle size and performance impact
   - Look for simpler, well-established alternatives first

### When Uncertain

If you're unsure whether a technology is stable enough:
1. **Check the version number**: Semantic versioning < 1.0.0 suggests pre-release
2. **Check the documentation**: Look for "beta", "experimental", "preview" warnings
3. **Check the release date**: Very new projects may not be battle-tested
4. **Ask the user**: When in doubt, present options and ask for guidance

## Git Workflow Requirements

### Branch Structure (CRITICAL)

**MANDATORY**: All projects must follow this branch workflow:

- **`main`** - Production branch
  - **NEVER commit directly to main**
  - Protected branch - requires PR review
  - Only accepts merges from `dev` (or `staging` if it exists)
  - Represents production-ready code

- **`dev`** - Development branch
  - **ALL development work happens here**
  - Default working branch for all changes
  - Test changes here before merging to main
  - Can be pushed to directly (no PR required for dev work)

- **`staging`** (optional, if project uses it)
  - Pre-production testing environment
  - Bridge between `dev` and `main`
  - Use if project has staging deployment

### Daily Development Workflow

```bash
# ALWAYS start here
git checkout dev
git pull origin dev

# Make changes, test locally
# ... do your work ...

# Commit frequently (see commit guidelines below)
git add .
git commit -m "Descriptive message"
git push origin dev
```

### Merging to Main

```bash
# NEVER do this:
git checkout main
git commit -m "changes"  # ❌ WRONG - never commit directly to main

# ALWAYS do this:
git checkout dev
# ... make changes and commit to dev ...
git push origin dev

# When ready for production:
git checkout main
git pull origin main
git merge dev
git push origin main
```

### Commit Guidelines

**Commit Frequency**:
- Commit after each logical unit of work
- Commit BEFORE switching tasks
- Commit BEFORE merging branches
- DO NOT accumulate many changes before committing

**Commit Message Format**:
- Use descriptive, clear messages
- Use present tense, imperative mood (e.g., "Add feature" not "Added feature")
- Be specific about what changed and why
- First line: concise summary (50 chars or less)

**Anatomical Commits for Debugging**:
- Each commit should represent a single logical change
- Keep commits atomic - one purpose per commit
- This enables easier debugging and evaluation of agent-written code
- Makes it possible to bisect, revert, or cherry-pick specific changes
- Helps reviewers understand the evolution of the code

**Required Co-Author Tag**:
ALL commits must include:
```
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Example Commit**:
```
Add user authentication with Supabase

Implement sign-in/sign-up flow using Supabase auth.
Includes email/password and OAuth providers.

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Python Development

### Environment & Tools
- **Version**: Python 3.12+ (stable)
- **Package Manager**: pip
- **Virtual Environments**: Always use venv or virtualenv
- **Linting & Formatting**: Ruff
  - Single tool replacing Flake8, Black, and isort
  - Fast, modern, comprehensive
  - Configuration in `pyproject.toml`

### Python Package Selection
- Prefer standard library when possible
- Use well-established packages (e.g., requests, pandas, pytest)
- Avoid unmaintained or experimental packages
- Check PyPI for download stats and last update date

## JavaScript/TypeScript Development

### Code Quality & Formatting
- **ESLint**: Comprehensive linting
- **Prettier**: Code formatting
- **TypeScript Strict Mode**: Type safety
- All three work together

### Library Selection
- Prefer React ecosystem standards
- Use npm registry download stats as indicator of adoption
- Check for TypeScript support
- Verify recent maintenance activity

## Security Requirements

**CRITICAL**: Security is the highest priority. User is a cybersecurity professional.

### Required Security Practices

1. **Dependency Scanning**
   - Run `npm audit` or `pip-audit` regularly
   - Address high/critical vulnerabilities immediately
   - Keep dependencies up to date

2. **Secret Scanning**
   - Use tools like gitleaks or trufflehog
   - Never commit secrets, API keys, or credentials
   - Use environment variables for sensitive data
   - Check `.env` files are in `.gitignore`

3. **Pre-commit Hooks**
   - Set up husky (JavaScript) or pre-commit (Python)
   - Run linting, formatting, and security checks
   - Block commits with secrets or vulnerabilities

4. **Security-First Development**
   - Build security in from day one
   - Never take security shortcuts, even in development
   - Follow RBAC principles
   - Use principle of least privilege for all integrations

### Security Mindset

- **Never compromise security for convenience**
- **Never use admin/full-access keys** - always use restricted permissions
- **Never skip security checks** because "it's just a test"
- **Always validate and sanitize inputs**
- **Always use parameterized queries** to prevent SQL injection
- **Always implement proper authentication and authorization**

## Verification Checklist

Before recommending or implementing any technology:

- [ ] Is this a stable, production-ready version?
- [ ] Is this widely used and well-supported?
- [ ] Does this have active maintenance?
- [ ] Are there any known security vulnerabilities?
- [ ] Is this simpler than alternatives?
- [ ] Does this follow the user's stated preferences?
- [ ] Am I working on the correct branch (dev, not main)?
- [ ] Are my commits atomic and well-described?
- [ ] Have I included security considerations?

## When to Ask the User

Always ask the user when:
- Only experimental/beta options are available
- Choosing between equally viable stable options
- Security implications are unclear
- Deviating from these guidelines is necessary
- Unsure if a library meets stability criteria

## Updates

This file should be updated when development practices or preferences change.

**Last Updated**: 2026-02-02
