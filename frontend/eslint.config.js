import js from '@eslint/js';
import svelte from 'eslint-plugin-svelte';
import globals from 'globals';
import ts from 'typescript-eslint';

/** @type {import('eslint').Linter.Config[]} */
export default [
    js.configs.recommended,
    ...ts.configs.recommended,
    ...svelte.configs['flat/recommended'],

    {
        languageOptions: {
            globals: {
                ...globals.browser,
                ...globals.node,
            },
        },
    },

    {
        files: ['**/*.svelte'],
        languageOptions: {
            parserOptions: {
                // Required for TypeScript inside <script lang="ts"> in Svelte files.
                parser: ts.parser,
            },
        },
    },

    {
        // Rules that apply to all files.
        rules: {
            // Enforce explicit return types on functions for clarity.
            '@typescript-eslint/explicit-function-return-type': ['warn', {
                allowExpressions: true,
                allowTypedFunctionExpressions: true,
            }],

            // Disallow use of `any` — keep code fully typed.
            '@typescript-eslint/no-explicit-any': 'error',

            // Disallow unused variables except those prefixed with _.
            '@typescript-eslint/no-unused-vars': ['error', {
                argsIgnorePattern: '^_',
                varsIgnorePattern: '^_',
            }],

            // Prefer const over let where possible.
            'prefer-const': 'error',
        },
    },

    {
        // Ignored paths — build output, generated files, and dependencies.
        ignores: [
            '.svelte-kit/',
            'build/',
            'node_modules/',
        ],
    },
];
