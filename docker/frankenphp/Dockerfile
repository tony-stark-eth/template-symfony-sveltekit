# syntax=docker/dockerfile:1

# ============================================================
# Stage: frankenphp_base
# Shared foundation: PHP extensions, Composer, runtime config
# ============================================================
FROM dunglas/frankenphp:php8.4 AS frankenphp_base

WORKDIR /app

# Install system dependencies required by PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions via install-php-extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    pdo_pgsql \
    intl \
    zip \
    opcache \
    apcu

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set FrankenPHP Symfony runtime
ENV RUNTIME="Runtime\\FrankenPhpSymfony\\Runtime"

# Copy Caddyfile and entrypoint
COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile
COPY docker/frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]

# ============================================================
# Stage: frankenphp_dev
# Development stage: Xdebug (optional), Supercronic, Symfony CLI
# ============================================================
FROM frankenphp_base AS frankenphp_dev

ENV APP_ENV=dev
ENV APP_DEBUG=1
ENV XDEBUG_MODE=off

# Install Xdebug — used for step-debugging AND code coverage.
# PCOV is not an option: FrankenPHP uses ZTS (thread-safe) PHP and PCOV only supports NTS.
# Coverage is collected via XDEBUG_MODE=coverage (set per-command, default off).
RUN install-php-extensions xdebug

# Install Supercronic for cron job execution in containers
ARG SUPERCRONIC_VERSION=v0.2.33
ARG SUPERCRONIC_SHA1SUM_AMD64=71b0d58cc53f6bd72cf2f293e09e294b79c666d8
ARG SUPERCRONIC_SHA1SUM_ARM64=e0f0c06ebc5627e43b25475711e694450489ab00
ARG TARGETARCH
RUN set -eux; \
    if [ "$TARGETARCH" = "arm64" ]; then \
        SUPERCRONIC_SHA1SUM=$SUPERCRONIC_SHA1SUM_ARM64; \
    else \
        SUPERCRONIC_SHA1SUM=$SUPERCRONIC_SHA1SUM_AMD64; \
    fi; \
    curl -fsSLo /usr/local/bin/supercronic \
        "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}"; \
    echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c -; \
    chmod +x /usr/local/bin/supercronic

# Install Symfony CLI for debug tooling (profiler, console helpers)
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

# ============================================================
# Stage: frankenphp_prod
# Production stage: rootless, Debian Slim, worker mode
# Target image size: ~290 MB
# ============================================================
FROM dunglas/frankenphp:php8.4 AS frankenphp_prod

WORKDIR /app

# Install PHP extensions (same set as base, minus dev tools)
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    pdo_pgsql \
    intl \
    zip \
    opcache \
    apcu

# Install Composer (needed to install dependencies)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy Caddyfile
COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

# Copy application source
COPY backend/ .

# Install production dependencies only (no dev packages)
RUN composer install --no-dev --optimize-autoloader --no-scripts && \
    composer dump-autoload --optimize --no-dev && \
    composer run-script --no-dev post-install-cmd; \
    true

# OPcache preload — Symfony generates this file at cache:warmup
RUN php bin/console cache:warmup --env=prod 2>/dev/null || true

# Production PHP ini settings
RUN { \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=256'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.max_accelerated_files=20000'; \
    echo 'opcache.validate_timestamps=0'; \
    echo 'opcache.save_comments=1'; \
    echo 'opcache.preload=/app/var/cache/prod/srcApp_KernelProdContainer.preload.php'; \
    echo 'opcache.preload_user=www-data'; \
    echo 'realpath_cache_size=4096K'; \
    echo 'realpath_cache_ttl=600'; \
    } > /usr/local/etc/php/conf.d/prod-opcache.ini

# Security: remove setuid/setgid bits (reduces attack surface in rootless container)
RUN find / -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

# Run as non-root (rootless)
RUN useradd --no-create-home --uid 1001 appuser && \
    chown -R appuser:appuser /app
USER appuser

ENV APP_ENV=prod
ENV APP_DEBUG=0
# Worker mode: FrankenPHP keeps the PHP process alive between requests
ENV FRANKENPHP_CONFIG="worker ./public/index.php"
