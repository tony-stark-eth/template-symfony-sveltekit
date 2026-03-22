import { defineConfig, devices } from '@playwright/test';

/**
 * E2E tests run against the full stack:
 * - Frontend: SvelteKit dev server on port 5173 (via Docker bun service)
 * - Backend: FrankenPHP on port 443 (via Docker php service)
 *
 * Run locally:
 *   docker compose --profile dev up -d
 *   cd frontend && bun run test:e2e
 */
export default defineConfig({
    testDir: './tests/e2e',
    fullyParallel: true,
    forbidOnly: !!process.env['CI'],
    retries: process.env['CI'] ? 2 : 1,
    workers: process.env['CI'] ? 1 : 2,
    reporter: 'html',

    use: {
        // In dev mode, the Vite dev server proxies /api to FrankenPHP.
        baseURL: process.env['BASE_URL'] ?? 'http://localhost:5173',
        trace: 'on-first-retry',
    },

    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
    ],
});
