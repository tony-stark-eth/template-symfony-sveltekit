import { sveltekit } from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

export default defineConfig({
    plugins: [tailwindcss(), sveltekit()],
    server: {
        proxy: {
            // Proxy API requests to the FrankenPHP backend container.
            // In production, Caddy serves both the static frontend and the
            // PHP API under a single domain — no proxy needed there.
            '/api': {
                // VITE_API_PROXY_TARGET allows overriding the backend URL.
                // Default: https://php (Docker service name, works inside Docker Compose).
                // For local non-Docker dev set VITE_API_PROXY_TARGET=https://localhost
                // http://php:8080 = plain HTTP internal listener (no TLS cert mismatch).
                // Override with VITE_API_PROXY_TARGET for non-Docker dev.
                target: process.env['VITE_API_PROXY_TARGET'] ?? 'http://php:8080',
                changeOrigin: true,
            },
            '/.well-known/mercure': {
                target: process.env['VITE_API_PROXY_TARGET'] ?? 'http://php:8080',
                changeOrigin: true,
                ws: true,
            },
        },
    },
});
