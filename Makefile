.PHONY: help up down build logs shell quality ecs ecs-check phpstan rector rector-check test test-unit test-integration infection infection-fast frontend-install frontend-dev frontend-build frontend-check frontend-lint db-migrate db-diff db-reset tofu-init tofu-plan tofu-apply

help:                 ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ── Docker ──────────────────────────────────────────────
up:                   ## Start Docker Compose (dev)
	docker compose --profile dev up -d

down:                 ## Stop Docker Compose
	docker compose --profile dev down

build:                ## Rebuild Docker images
	docker compose build --pull --no-cache

logs:                 ## Follow all service logs
	docker compose logs -f

shell:                ## Shell into PHP container
	docker compose exec php sh

# ── Backend Quality ─────────────────────────────────────
quality:              ## Run all backend checks locally
	@$(MAKE) ecs-check phpstan rector-check test infection

hooks:                ## Install git hooks (CaptainHook) — run once after cloning
	cd backend && vendor/bin/captainhook install --force --skip-existing

ecs:                  ## Coding standard (fix)
	cd backend && vendor/bin/ecs check --fix

ecs-check:            ## Coding standard (check only)
	cd backend && vendor/bin/ecs check

phpstan:              ## Static analysis
	cd backend && vendor/bin/phpstan analyse

rector:               ## Rector auto-fix
	cd backend && vendor/bin/rector process

rector-check:         ## Rector dry-run
	cd backend && vendor/bin/rector process --dry-run

# ── Backend Tests ───────────────────────────────────────
test:                 ## PHPUnit (all suites)
	cd backend && vendor/bin/phpunit

test-unit:            ## Unit tests with coverage
	cd backend && vendor/bin/phpunit --testsuite=unit --coverage-html=var/coverage

test-integration:     ## Integration tests only
	cd backend && vendor/bin/phpunit --testsuite=integration

infection:            ## Mutation testing
	cd backend && vendor/bin/infection --threads=4 --show-mutations

infection-fast:       ## Mutation testing (changed files only)
	cd backend && vendor/bin/infection --threads=4 --git-diff-filter=AM --git-diff-base=origin/main

# ── Frontend ────────────────────────────────────────────
frontend-install:     ## Bun install
	cd frontend && bun install

frontend-dev:         ## SvelteKit dev server
	cd frontend && bun run dev

frontend-build:       ## SvelteKit production build
	cd frontend && bun run build

frontend-check:       ## TypeScript + Svelte check
	cd frontend && bun run check

frontend-lint:        ## ESLint
	cd frontend && bun run lint

e2e:                  ## E2E tests (requires docker compose --profile dev up -d)
	cd frontend && bun run test:e2e

e2e-ui:               ## E2E tests with Playwright UI
	cd frontend && bun run test:e2e:ui

# ── Database ────────────────────────────────────────────
db-migrate:           ## Run Doctrine migrations
	docker compose exec php php bin/console doctrine:migrations:migrate --no-interaction

db-diff:              ## Generate migration diff
	docker compose exec php php bin/console doctrine:migrations:diff

db-reset:             ## Drop + create + migrate database
	docker compose exec php php bin/console doctrine:database:drop --force --if-exists
	docker compose exec php php bin/console doctrine:database:create
	docker compose exec php php bin/console doctrine:migrations:migrate --no-interaction

# ── Infrastructure ──────────────────────────────────────
tofu-init:            ## OpenTofu init
	cd infrastructure && tofu init

tofu-plan:            ## OpenTofu plan (dry-run)
	cd infrastructure && tofu plan

tofu-apply:           ## OpenTofu apply (WARNING: creates real resources!)
	cd infrastructure && tofu apply
