import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
    preprocess: vitePreprocess(),

    kit: {
        // adapter-static = SPA mode, no SSR.
        // Suitable for apps behind authentication where SEO is not required.
        // To add SSR for public pages, switch to adapter-node or adapter-auto.
        adapter: adapter({
            // Single-page app mode: all routes fall back to index.html
            fallback: 'index.html',
        }),
    },
};

export default config;
