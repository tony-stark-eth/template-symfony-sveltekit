# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-03-21

### Added

- PHP 8.4 + Symfony 8 backend running on FrankenPHP in Worker Mode
- SvelteKit 2 + Svelte 5 frontend with Bun as package manager and runtime
- TypeScript strict mode and Tailwind CSS 4 pre-configured for the frontend
- Docker Compose setup with FrankenPHP, PostgreSQL 17, and PgBouncer (Transaction Mode)
- 10 PHPStan extensions pre-configured at level max:
  - `phpstan-strict-rules`
  - `phpstan-deprecation-rules`
  - `shipmonk/phpstan-rules`
  - `voku/phpstan-rules`
  - `tomasvotruba/cognitive-complexity`
  - `tomasvotruba/type-coverage`
  - `phpat/phpat` for architecture tests
  - `phpstan-symfony`
  - `phpstan-doctrine`
  - `phpstan-phpunit`
- Rector for automated PHP refactoring with dry-run CI check
- Easy Coding Standard (ECS) for PHP code style enforcement
- PHPUnit 13 test suite with unit and integration test suites
- Infection mutation testing with MSI ≥ 80% and Covered MSI ≥ 90% thresholds
- GitHub Actions CI pipeline for backend (`ci.yml`): ECS, PHPStan, Rector, PHPUnit, Infection
- GitHub Actions CI pipeline for frontend (`ci-frontend.yml`): ESLint, Svelte Check, build
- Claude Code integration: `CLAUDE.md` entry point, `.claude/` guidelines directory
- Automated biweekly dependency updates via Claude Code (`claude-update.yml`)
- Automated code review on every pull request via Claude Code (`claude-review.yml`)
- Dependabot configuration for automated dependency update pull requests
- Makefile with all common development targets (`make help` for full list)
- OpenTofu infrastructure modules for Hetzner Cloud deployment
- `.env.example` with all required environment variable placeholders documented
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, and `LICENSE` (MIT)
- GitHub issue templates for bug reports and feature requests
- `CODEOWNERS` file

[Unreleased]: https://github.com/tony-stark-eth/template-symfony-sveltekit/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/tony-stark-eth/template-symfony-sveltekit/releases/tag/v1.0.0
