---
name: docker-best-practices
description: Docker containerization patterns for development and production. Use when setting up dev containers, configuring docker-compose, building Docker images, or debugging containerized apps. Guides binding policies, dev vs prod distinction, and hot reload setups.
---

# Docker Best Practices

Opinionated Docker patterns for development and production workflows. Emphasizes clear separation between dev (docker-compose with hot reload) and production (Dockerfile with optimized images), and proper port binding for debuggability.

## When to Apply

Reference these guidelines when:

- Setting up docker-compose for local development
- Writing Dockerfiles for production builds
- Configuring port bindings for debugging
- Setting up hot reload in containers
- Troubleshooting Docker-based development workflows

## Rule Categories

| Priority | Category        | Impact   | Prefix         |
| -------- | --------------- | -------- | -------------- |
| 1        | Dev Environment | CRITICAL | `dev-compose-` |
| 2        | Dev vs Prod     | CRITICAL | `dev-vs-prod-` |
| 3        | Hot Reload      | HIGH     | `hot-reload-`  |
| 4        | Docker Images   | HIGH     | `image-output-`|

## Quick Reference

### 1. Dev Environment (CRITICAL)

- `dev-compose-binding-0-0-0-0` - Bind services to 0.0.0.0 for external inspection

### 2. Dev vs Prod (CRITICAL)

- `dev-vs-prod-distinction` - docker-compose.yml for dev only; Dockerfile for prod

### 3. Hot Reload (HIGH)

- `hot-reload-volume-mounts` - Mount source code directories and exclude node_modules

### 4. Docker Images (HIGH)

- `image-output-api-services` - Multi-stage Dockerfiles for optimized production images

## How to Use

Read individual rule files for detailed explanations and patterns:

```
rules/dev-compose-binding-0-0-0-0.md
rules/dev-vs-prod-distinction.md
rules/hot-reload-volume-mounts.md
rules/image-output-api-services.md
```

Each rule file contains:

- Brief explanation of why it matters
- Correct patterns with explanation
- Context and references
