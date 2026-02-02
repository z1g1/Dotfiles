# Technology Preferences

This document defines the preferred technology stack and tooling choices for projects. Claude Code should consult this file when making technology decisions.

## Core Stack

### Backend Runtime
- **Preference**: React JS (for frontend development)
- **Note**: User indicated "React JS" for runtime question - likely meant for frontend. For actual backend runtime, defer to project context.

### Frontend Framework
- **Preference**: React
- **Rationale**: Popular, flexible library with large ecosystem

### Styling
- **Preference**: Tailwind CSS
- **Approach**: Utility-first CSS framework for rapid development

### Database
- **Preference**: Supabase
- **Benefits**: PostgreSQL with built-in auth, realtime, and API layer

## Development Tools

### Testing
- **Unit/Integration Tests**: Vitest
  - Fast, Vite-native testing framework
  - Jest-compatible API
- **E2E/UI Tests**: Playwright
  - Use for interactive testing of the UI
  - End-to-end testing for web applications

### Package Management
- **Preference**: npm
- **Standard**: Use npm for all package management tasks

### Build Tool/Bundler
- **Preference**: No strong opinion yet
- **Recommendation**: Consider Vite for React projects (fast, modern, great DX)
- **Alternative**: Next.js if full-stack React framework is needed

### TypeScript
- **Strictness Level**: Strict
- **Configuration**: Enable all strict checks for maximum type safety
- **Approach**: Type-first development with comprehensive type coverage

## Decision Guidelines

When starting new projects or adding dependencies:

1. **Default to the preferences above** unless project-specific requirements dictate otherwise
2. **Use stable, supported versions** - avoid experimental/beta unless explicitly requested
3. **Consider security implications** - follow the security guidelines in CLAUDE.md
4. **Document deviations** - if project requirements force different choices, document why

## Framework-Specific Patterns

### React Projects
- Use functional components with hooks
- Prefer TypeScript with strict mode
- Use Tailwind for styling
- Vitest for component testing
- Playwright for E2E testing

### Database (Supabase)
- Use Supabase client libraries
- Leverage built-in auth when possible
- Use Row Level Security (RLS) policies
- Follow RBAC principles from day one

## Updates

This file should be updated when technology preferences change. Always consult with the user before making major technology decisions that deviate from these preferences.

**Last Updated**: 2026-02-02
