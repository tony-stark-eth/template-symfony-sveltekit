import { test, expect } from '@playwright/test';

/**
 * E2E smoke tests — verify the full stack is wired up correctly.
 *
 * These tests require:
 *   docker compose --profile dev up -d
 *
 * They confirm:
 *   1. The frontend loads and is served by the Vite dev server (or Caddy in prod).
 *   2. The Symfony API health endpoint is reachable through the Vite proxy.
 *   3. The ready endpoint can connect to the database.
 */

test.describe('Stack smoke tests', () => {
    test('frontend renders the landing page', async ({ page }) => {
        await page.goto('/');

        // The page should load without a network error.
        await expect(page).toHaveTitle(/.*/, { timeout: 10_000 });

        // The body should contain something — not a blank error page.
        const body = await page.locator('body').textContent();
        expect(body).not.toBeNull();
        expect((body ?? '').length).toBeGreaterThan(0);
    });

    test('API health endpoint returns ok', async ({ request }) => {
        const response = await request.get('/api/v1/health');

        expect(response.status()).toBe(200);

        const body = await response.json() as { status: string; timestamp: string };
        expect(body.status).toBe('ok');
        expect(body.timestamp).toBeTruthy();
    });

    test('API ready endpoint confirms database connectivity', async ({ request }) => {
        const response = await request.get('/api/v1/health/ready');

        // 200 = database is reachable; 503 = database is down.
        // In a healthy stack this must be 200.
        expect(response.status()).toBe(200);

        const body = await response.json() as { status: string };
        expect(body.status).toBe('ok');
    });
});
