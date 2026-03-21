# Symfony + SvelteKit Template

[![Backend CI](https://github.com/tony-stark-eth/template-symfony-sveltekit/actions/workflows/ci.yml/badge.svg)](https://github.com/tony-stark-eth/template-symfony-sveltekit/actions/workflows/ci.yml)
[![Frontend CI](https://github.com/tony-stark-eth/template-symfony-sveltekit/actions/workflows/ci-frontend.yml/badge.svg)](https://github.com/tony-stark-eth/template-symfony-sveltekit/actions/workflows/ci-frontend.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PHPStan Level max](https://img.shields.io/badge/PHPStan-level%20max-brightgreen.svg)](https://phpstan.org/)

Opinionated full-stack template for PHP 8.4 + Symfony 8 + SvelteKit projects.
Production-ready quality tooling from commit zero.

## What's Included

| Layer | Technologies |
|---|---|
| **Backend** | PHP 8.4, Symfony 8, Doctrine ORM, FrankenPHP (Worker Mode) |
| **Frontend** | SvelteKit 2, Svelte 5, Bun, TypeScript strict, Tailwind 4 |
| **Database** | PostgreSQL 17, PgBouncer (Transaction Mode) |
| **Quality** | 10 PHPStan extensions, Rector, ECS, PHPUnit 13, Infection |
| **CI/CD** | GitHub Actions (backend + frontend), Dependabot auto-merge |
| **AI** | Claude Code integration via `CLAUDE.md` + `.claude/` guidelines |
| **Infrastructure** | OpenTofu modules for Hetzner deployment |

## Quick Start

> **Prerequisites**: Docker, Bun, Make

```bash
# 1. Use this template (green button above) or clone via gh
gh repo create my-project --template tony-stark-eth/template-symfony-sveltekit --private

# 2. Start containers
docker compose --profile dev up -d

# 3. Install dependencies
cd backend && composer install && cd ..
cd frontend && bun install && cd ..

# 4. Run all quality checks
make quality
```

## After Forking — Checklist

- [ ] Update `composer.json` name and description
- [ ] Update `package.json` name
- [ ] Generate JWT keys: `php bin/console lexik:jwt:generate-keypair`
- [ ] Copy `.env.example` to `.env.local` and fill in real secrets
- [ ] Add `ANTHROPIC_API_KEY` as a GitHub repository secret (required for Claude workflows)
- [ ] Create domain folders under `backend/src/` (e.g. `src/User/`, `src/Product/`)
- [ ] Add project-specific phpat architecture rules in `tests/Architecture/`
- [ ] Update `CLAUDE.md` with project-specific context
- [ ] Remove this checklist from README

## Quality Stack

| Tool | What it enforces |
|---|---|
| PHPStan Level max | Type safety, dead code, logic errors |
| phpstan-strict-rules | `===`, no `empty()`, strict `in_array()` |
| phpstan-deprecation-rules | No deprecated API usage |
| shipmonk/phpstan-rules | ~40 rules: enum safety, forgotten exceptions, custom bans |
| voku/phpstan-rules | Operator type safety, assignment-in-condition |
| tomasvotruba/cognitive-complexity | Max 8/method, max 50/class |
| tomasvotruba/type-coverage | 100% type declarations required |
| phpat/phpat | Architecture tests (layer dependencies, naming conventions) |
| phpstan-symfony | Container-aware analysis, route parameter checking |
| phpstan-doctrine | Entity mapping validation, repository return types |
| phpstan-phpunit | Mock type inference, assertion analysis |
| Infection | Mutation testing: MSI ≥ 80%, Covered MSI ≥ 90% |

## Make Targets

Run `make help` for a full list. Most commonly used:

| Target | Description |
|---|---|
| `make up` | Start all Docker services (dev profile) |
| `make down` | Stop all Docker services |
| `make quality` | Run all backend quality checks (ECS, PHPStan, Rector, PHPUnit, Infection) |
| `make phpstan` | Static analysis only |
| `make ecs` | Coding standard auto-fix |
| `make rector` | Rector auto-fix |
| `make test` | PHPUnit (all suites) |
| `make test-unit` | Unit tests with HTML coverage report |
| `make test-integration` | Integration tests only |
| `make infection` | Full mutation testing run |
| `make infection-fast` | Mutation testing on changed files only |
| `make frontend-dev` | SvelteKit dev server |
| `make frontend-build` | SvelteKit production build |
| `make frontend-check` | TypeScript + Svelte type check |
| `make frontend-lint` | ESLint |
| `make db-migrate` | Run Doctrine migrations |
| `make db-reset` | Drop, recreate, and migrate database |
| `make shell` | Shell into the PHP container |
| `make tofu-plan` | OpenTofu infrastructure dry-run |
| `make tofu-apply` | OpenTofu apply (creates real resources) |

## CI / GitHub Actions

| Workflow | Runs | Steps |
|---|---|---|
| `ci.yml` | Every push / PR | ECS → PHPStan → Rector → PHPUnit → Infection |
| `ci-frontend.yml` | Every push / PR | ESLint → Svelte Check → Build |
| `claude-update.yml` | Biweekly | Dependency updates via Claude Code with breaking-change resolution |
| `claude-review.yml` | Every PR | Automatic code review posted as PR comment |

Default: GitHub-hosted runners. For self-hosted runners: set the repository variable
`RUNNER_LABEL` to your runner label.

## Claude Code

This template ships with full Claude Code integration out of the box:

- `CLAUDE.md` — entry point read automatically by Claude Code on every session
- `.claude/` — coding guidelines (PHP, frontend, testing, architecture)
- `claude-review.yml` — automatic code review on every pull request
- `claude-update.yml` — biweekly dependency updates with AI-assisted conflict resolution

**Required secret**: Add `ANTHROPIC_API_KEY` to your repository secrets.
Without it, the Claude workflows will skip silently.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). TL;DR: fork, branch, `make quality`, PR.

## License

[MIT](LICENSE) — Copyright (c) 2026 tony-stark-eth
