<script lang="ts">
    import '../app.css';

    // ---------------------------------------------------------------------------
    // Dark mode toggle — Svelte 5 runes syntax
    // ---------------------------------------------------------------------------

    // Possible theme values stored in localStorage and applied to <html>.
    type Theme = 'light' | 'dark' | 'system';

    function getInitialTheme(): Theme {
        if (typeof localStorage === 'undefined') return 'system';
        const stored = localStorage.getItem('theme');
        if (stored === 'light' || stored === 'dark' || stored === 'system') return stored;
        return 'system';
    }

    function resolveEffectiveTheme(theme: Theme): 'light' | 'dark' {
        if (theme !== 'system') return theme;
        return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }

    function applyTheme(theme: Theme): void {
        const effective = resolveEffectiveTheme(theme);
        document.documentElement.setAttribute('data-theme', effective);
        if (theme === 'system') {
            document.documentElement.removeAttribute('data-theme');
        } else {
            document.documentElement.setAttribute('data-theme', effective);
        }
        localStorage.setItem('theme', theme);
    }

    let theme = $state<Theme>(getInitialTheme());

    $effect(() => {
        applyTheme(theme);
    });

    // ---------------------------------------------------------------------------
    // Health check
    // ---------------------------------------------------------------------------

    type HealthStatus = 'idle' | 'loading' | 'ok' | 'error';

    let healthStatus = $state<HealthStatus>('idle');
    let healthMessage = $state<string>('');

    async function checkHealth(): Promise<void> {
        healthStatus = 'loading';
        healthMessage = '';
        try {
            const res = await fetch('/api/v1/health');
            if (res.ok) {
                const data = (await res.json()) as { status?: string };
                healthMessage = data.status ?? 'ok';
                healthStatus = 'ok';
            } else {
                healthMessage = `HTTP ${res.status}`;
                healthStatus = 'error';
            }
        } catch (err) {
            healthMessage = err instanceof Error ? err.message : 'Unknown error';
            healthStatus = 'error';
        }
    }

    // ---------------------------------------------------------------------------
    // Derived label for the toggle button
    // ---------------------------------------------------------------------------
    const themeLabel = $derived(
        theme === 'light' ? 'Switch to dark mode'
        : theme === 'dark' ? 'Switch to system mode'
        : 'Switch to light mode'
    );

    const themeIcon = $derived(
        theme === 'light' ? '☀️'
        : theme === 'dark' ? '🌙'
        : '💻'
    );

    function cycleTheme(): void {
        if (theme === 'system') theme = 'light';
        else if (theme === 'light') theme = 'dark';
        else theme = 'system';
    }
</script>

<main class="min-h-dvh flex flex-col items-center justify-center gap-8 p-6">
    <header class="text-center space-y-2">
        <h1 class="text-4xl font-bold tracking-tight" style="color: var(--color-text-primary)">
            Symfony + SvelteKit
        </h1>
        <p class="text-lg" style="color: var(--color-text-secondary)">
            Template — replace this with your app branding
        </p>
    </header>

    <!-- Dark mode toggle -->
    <section
        class="rounded-xl border p-6 w-full max-w-sm space-y-3"
        style="background: var(--color-surface); border-color: var(--color-border);"
    >
        <h2 class="text-sm font-semibold uppercase tracking-wider" style="color: var(--color-text-muted)">
            Theme
        </h2>
        <div class="flex items-center gap-3">
            <button
                onclick={cycleTheme}
                class="flex items-center gap-2 px-4 py-2 rounded-lg font-medium text-sm transition-colors cursor-pointer border"
                style="background: var(--color-accent); color: var(--color-accent-text); border-color: var(--color-accent);"
                aria-label={themeLabel}
            >
                <span aria-hidden="true">{themeIcon}</span>
                {theme.charAt(0).toUpperCase() + theme.slice(1)} mode
            </button>
            <span class="text-sm" style="color: var(--color-text-muted)">{themeLabel}</span>
        </div>
    </section>

    <!-- API health check -->
    <section
        class="rounded-xl border p-6 w-full max-w-sm space-y-3"
        style="background: var(--color-surface); border-color: var(--color-border);"
    >
        <h2 class="text-sm font-semibold uppercase tracking-wider" style="color: var(--color-text-muted)">
            API Health
        </h2>
        <p class="text-xs font-mono" style="color: var(--color-text-secondary)">
            GET /api/v1/health → proxied to FrankenPHP in dev
        </p>
        <button
            onclick={checkHealth}
            disabled={healthStatus === 'loading'}
            class="px-4 py-2 rounded-lg font-medium text-sm transition-colors cursor-pointer border disabled:opacity-50"
            style="background: var(--color-surface-raised); color: var(--color-text-primary); border-color: var(--color-border-strong);"
        >
            {healthStatus === 'loading' ? 'Checking…' : 'Check health'}
        </button>

        {#if healthStatus === 'ok'}
            <p class="text-sm font-mono" style="color: var(--color-success)">
                ✓ {healthMessage}
            </p>
        {:else if healthStatus === 'error'}
            <p class="text-sm font-mono" style="color: var(--color-error)">
                ✗ {healthMessage}
            </p>
        {/if}
    </section>

    <!-- Tech stack badges -->
    <footer class="flex flex-wrap gap-2 justify-center text-xs font-mono">
        {#each ['Svelte 5', 'SvelteKit 2', 'Tailwind 4', 'Symfony 8', 'TypeScript'] as tech (tech)}
            <span
                class="px-2 py-1 rounded-md border"
                style="color: var(--color-text-secondary); border-color: var(--color-border);"
            >
                {tech}
            </span>
        {/each}
    </footer>
</main>
