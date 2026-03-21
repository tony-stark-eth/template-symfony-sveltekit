# PHP Coding Guidelines

## Basics

- `declare(strict_types=1)` — first line of every PHP file, no exceptions
- `final readonly class` as default — only break if extension is needed
- `DateTimeImmutable` always, `DateTime` is forbidden (PHPStan enforced)
- Constructor Injection only — no Service Locator, no Property Injection

## Methods

- Max 20 lines per method
- Max 3 parameters — more → DTO or Value Object
- Cognitive Complexity max 8 (enforced via PHPStan)
- One abstraction level per method
- Method names are verbs: `findActiveHabits()`, not `habits()`

## Classes

- Max ~150 lines (excluding imports/docblocks)
- Cognitive Complexity max 50 per class (enforced via PHPStan)
- Max 5 dependencies in constructor
- `find*` may return null, `get*` throws exception

## Patterns

- Value Objects for domain concepts (no Primitive Obsession)
- Early Returns — max nesting depth 2
- Composition over Inheritance
- Immutability by Default
- Enums instead of magic values
- Specific exceptions, never swallowed

## Folder Structure

Domain-based, not framework-based:

```
src/
├── Feature/           ← per domain concept
│   ├── Controller/
│   ├── Entity/
│   ├── Repository/
│   ├── Service/
│   ├── Event/
│   ├── Exception/
│   └── ValueObject/
└── Shared/            ← cross-domain
```

Not: `src/Entity/`, `src/Service/`, `src/Controller/` as flat folders.

## Naming Conventions

- Controller: `{Feature}Controller`
- Service: `{Action}Service` or `{Feature}Handler`
- Exception: `{What}Exception` — must live in `Exception/` namespace (phpat enforced)
- Value Object: name describes the value, e.g. `Email`, `TimeWindow`, `InviteCode`
- Test: `{ClassUnderTest}Test`
- Enums: PascalCase Singular, e.g. `PushType`, `HabitFrequency`
