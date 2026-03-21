# Frontend Coding Guidelines

## TypeScript

- strict mode, no `any`
- `noUncheckedIndexedAccess: true`
- `noImplicitOverride: true`
- `exactOptionalPropertyTypes: true`

## Svelte 5

- Runes only: `$state()`, `$derived()`, `$effect()` — no legacy (`$:`, `let x = 0`)
- Max ~100 lines per component (template + script + style)
- Props with defaults and types, no `$$props` or `$$restProps`
- No business logic in components — extract to `$lib/` modules
- No direct `fetch` in components — use the API wrapper from `$lib/api/`

## Styling

- Tailwind 4 utility classes
- CSS Custom Properties for design tokens (colors, fonts, spacing)
- Dark Mode via CSS Custom Properties, not via Tailwind `dark:`
- Mobile-first

## i18n

- All visible strings as translation keys
- No hardcoded strings in components
- Files: `$lib/i18n/de.ts`, `$lib/i18n/en.ts`

## Accessibility

- ARIA labels on interactive elements
- Keyboard navigation
- WCAG AA contrast minimum
- Focus management for modals/dialogs
