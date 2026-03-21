# Contributing

Contributions are welcome! This template is meant to be opinionated but practical.

## How to contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-feature`)
3. Make sure all checks pass (`make quality`)
4. Commit with Conventional Commits (`feat:`, `fix:`, `docs:` etc.)
5. Open a Pull Request

## What we're looking for

- Bug fixes in Docker/CI configuration
- Improvements to PHPStan/Rector/ECS config
- Better defaults for the quality tooling
- Documentation improvements
- Additional Architecture Tests (phpat)

## What we're NOT looking for

- Domain-specific logic (this is a generic template)
- Alternative frameworks (no Laravel, no Next.js)
- Removing quality tools or lowering thresholds

## Development

```bash
docker compose --profile dev up -d
cd backend && composer install
cd frontend && bun install
make quality    # Must pass before opening a PR
```

## Code Style

This project enforces its own coding standards automatically. Run `make quality`
and fix everything it reports. Don't add `@phpstan-ignore` without a comment explaining why.
