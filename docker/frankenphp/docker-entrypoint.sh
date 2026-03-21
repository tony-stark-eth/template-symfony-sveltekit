#!/bin/sh
set -e

# Auto-install Composer dependencies if vendor/ is missing.
# This is the expected behaviour for a template repository:
# clone, docker compose up, and it just works — no manual "composer install" needed.
if [ ! -d /app/vendor ]; then
    echo "vendor/ not found — running composer install..."
    COMPOSER_MEMORY_LIMIT=-1 composer install \
        --no-interaction \
        --optimize-autoloader \
        --no-scripts
    echo "composer install done."
fi

exec docker-php-entrypoint "$@"
