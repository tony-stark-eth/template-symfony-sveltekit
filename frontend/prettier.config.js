/** @type {import('prettier').Config} */
export default {
    // Core formatting
    printWidth: 100,
    tabWidth: 4,
    useTabs: false,
    semi: true,
    singleQuote: true,
    quoteProps: 'as-needed',
    trailingComma: 'all',
    bracketSpacing: true,
    bracketSameLine: false,
    arrowParens: 'always',
    endOfLine: 'lf',

    // Svelte-specific formatting via prettier-plugin-svelte.
    plugins: ['prettier-plugin-svelte'],

    overrides: [
        {
            files: '*.svelte',
            options: {
                // Use the Svelte parser for .svelte files.
                parser: 'svelte',
                // Keep Svelte attribute order intact.
                svelteSortOrder: 'options-scripts-markup-styles',
                svelteStrictMode: false,
                svelteBracketNewLine: true,
                svelteIndentScriptAndStyle: true,
            },
        },
        {
            // JSON files use 2-space indentation (common convention).
            files: '*.json',
            options: {
                tabWidth: 2,
            },
        },
    ],
};
