# Claude Code Instructions

## Quick Start

```
docker compose --profile dev up -d
cd backend && composer install
cd frontend && bun install
make quality
```

## Project

Full-Stack Mono-Repo: `backend/` (Symfony 8 API) + `frontend/` (SvelteKit PWA).

## Guidelines

Coding and architecture rules in `.claude/`:

- `.claude/coding-php.md` — PHP Coding Guidelines
- `.claude/coding-frontend.md` — Svelte / TypeScript Guidelines
- `.claude/testing.md` — Testing, PHPStan, CI Pipeline
- `.claude/architecture.md` — Docker, DB, Folder Structure, Patterns

## Rules

- No React — Svelte 5 or plain JS only
- No `DateTime` — use `DateTimeImmutable` only
- No `var_dump`/`dump`/`dd`
- No `ignoreErrors` in phpstan.neon
- No `empty()`
- Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
