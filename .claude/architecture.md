# Architecture

## Project Type

Full-Stack Mono-Repo: `backend/` (PHP API) + `frontend/` (SvelteKit PWA).
All communication via REST API (`/api/v1/`).

## Docker

- **FrankenPHP** (Caddy + PHP 8.4) — single container for web + worker
- **PostgreSQL 17** — primary database
- **PgBouncer** — Transaction Mode for web requests
- **Messenger Worker** — connects DIRECTLY to DB, NOT through PgBouncer (LISTEN/NOTIFY)
- **Bun** — SvelteKit dev server (dev profile only)

## Conventions

- All timestamps in UTC — except explicit local-time fields (PostgreSQL `TIME`)
- Async: emails and push notifications via Symfony Messenger, never in the HTTP request
- API: plain controllers + Symfony Serializer, no API Platform
- Auth: JWT (Access Token 15min + Refresh Token 30d)
- i18n: paraglide-sveltekit (frontend) + Symfony Translator (backend)

## Makefile Targets

`make help` lists all available targets. Most common:

- `make up` / `make down` — start/stop Docker
- `make quality` — all backend checks (ECS, PHPStan, Rector, Test, Infection)
- `make test` / `make test-unit` / `make test-integration` — tests
- `make db-migrate` / `make db-diff` / `make db-reset` — database

## ENV Variables

Documented in `.env.example`. Key notes:
- `DATABASE_URL` → PgBouncer (web requests)
- `MESSENGER_DATABASE_URL` → direct PostgreSQL (worker)
- Separate URLs because PgBouncer Transaction Mode does not support LISTEN/NOTIFY
