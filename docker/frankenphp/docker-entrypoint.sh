#!/bin/sh
set -e

# ── Composer auto-install ────────────────────────────────────────────────
# Clone → docker compose up → it just works. No manual "composer install".
if [ ! -d /app/vendor ]; then
    echo "vendor/ not found — running composer install..."
    COMPOSER_MEMORY_LIMIT=-1 composer install \
        --no-interaction \
        --optimize-autoloader \
        --no-scripts
    echo "composer install done."
fi

# ── Wait for database ────────────────────────────────────────────────────
# Adapted from dunglas/symfony-docker. The PHP container may start before
# PostgreSQL is accepting connections (depends_on: service_healthy helps
# but is not bulletproof). Retry for up to 60 seconds.
if [ -f /app/bin/console ]; then
    MAX_RETRIES=60
    RETRY=0
    echo "Waiting for database to be ready..."
    until php bin/console dbal:run-sql -q "SELECT 1" 2>/dev/null; do
        RETRY=$((RETRY + 1))
        if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
            echo "ERROR: Database not reachable after ${MAX_RETRIES}s. Check DATABASE_URL and database service."
            # Don't exit — let FrankenPHP start anyway so healthchecks and logs are visible.
            break
        fi
        sleep 1
    done
    if [ "$RETRY" -lt "$MAX_RETRIES" ]; then
        echo "Database ready."
    fi

    # ── Auto-migrate ─────────────────────────────────────────────────────
    # Run pending Doctrine migrations on every container start.
    # Safe because Doctrine tracks which migrations have already been applied.
    # Uses --allow-no-migration so a template with zero migrations doesn't fail.
    echo "Running Doctrine migrations..."
    php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration 2>&1 || true
fi

exec docker-php-entrypoint "$@"
