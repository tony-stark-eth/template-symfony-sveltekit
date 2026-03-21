# Security Policy

## Supported Versions

This is a project template. Security fixes are applied to the `main` branch only.
There are no separate long-term-support branches.

| Version | Supported |
|---|---|
| latest (`main`) | Yes |
| older tags | No |

## Reporting a Vulnerability

**Do NOT open a public GitHub issue for security vulnerabilities.**

Use GitHub's built-in private vulnerability reporting instead:

1. Go to the repository on GitHub
2. Click **Security** in the top navigation
3. Click **Advisories**
4. Click **Report a vulnerability**

Alternatively, contact the maintainer directly via email (see the GitHub profile
of [@tony-stark-eth](https://github.com/tony-stark-eth)).

## Response Timeline

- **Acknowledgement**: within 48 hours of receiving the report
- **Initial assessment**: within 5 business days
- **Fix or mitigation**: timeline communicated after initial assessment
- **Public disclosure**: coordinated with the reporter after a fix is available

We follow responsible disclosure: reporters are credited in the security advisory
unless they request to remain anonymous.

## Scope

This repository is a **project template** — not a running application. The following
scope rules apply:

### In Scope

- Insecure default configuration in Docker Compose files
- Secrets or credentials committed to the repository
- CI workflow configuration that could expose secrets or allow privilege escalation
- Insecure default values in `.env.example` that could mislead users
- Misconfigured OpenTofu modules that could create overly permissive infrastructure

### Out of Scope

Security issues in **upstream dependencies** are not in scope for this repository.
Please report those to the relevant upstream projects:

- PHP / Symfony vulnerabilities: [symfony.com/security](https://symfony.com/security)
- PostgreSQL vulnerabilities: [postgresql.org/support/security](https://www.postgresql.org/support/security/)
- FrankenPHP / Caddy vulnerabilities: the respective upstream repositories
- SvelteKit / Vite vulnerabilities: the respective upstream repositories
- PHPStan, Rector, ECS, Infection: the respective upstream repositories

## Security Best Practices for Template Users

When you fork or use this template, ensure you:

- Replace all placeholder values in `.env.example` before deploying
- Generate fresh JWT key pairs: `php bin/console lexik:jwt:generate-keypair`
- Never commit `.env.local` or any file containing real secrets to version control
- Rotate secrets immediately if they are accidentally committed
- Review the Docker Compose configuration for your production environment
- Keep dependencies up to date (Dependabot is pre-configured for this)
