# Testing & Code Quality

## Composer Dev-Dependencies

14 packages — see `backend/composer.json`

## PHPStan — Level max + 10 Extensions

Configuration in `backend/phpstan.neon`. Extensions:

| Extension | What it checks |
|---|---|
| `phpstan-strict-rules` | `===`, no `empty()`, strict `in_array()` |
| `phpstan-deprecation-rules` | Deprecated code (PHP, Symfony, Doctrine) |
| `shipmonk/phpstan-rules` | ~40 rules: enum safety, forgotten exceptions, custom bans |
| `voku/phpstan-rules` | Operator type compatibility, assignment-in-condition |
| `tomasvotruba/cognitive-complexity` | function: 8, class: 50 |
| `tomasvotruba/type-coverage` | return: 100, param: 100, property: 100, constant: 100, declare: 100 |
| `phpat/phpat` | Architecture tests (layer dependencies, naming) |
| `phpstan-symfony` | Container-aware, route parameters |
| `phpstan-doctrine` | Entity mapping, repository return types |
| `phpstan-phpunit` | Mock type inference, assertion types |

Bleeding Edge flags active: `checkUninitializedProperties`, `checkImplicitMixed`,
`checkBenevolentUnionTypes`, `reportPossiblyNonexistentGeneralArrayOffset`

## PHPUnit 13

- Path Coverage via PCOV (not Xdebug)
- Two suites: `unit` (tests/Unit), `integration` (tests/Integration)
- `#[CoversClass(...)]` on every test class
- `createStub()` instead of `createMock()` where invocation verification is not needed
- Data Providers for edge cases

## Infection (Mutation Testing)

- Runs against unit suite only
- MSI >= 80%, Covered MSI >= 90%
- `infection-fast` for changed files only (CI optimization)

## Rector

- PHP 8.4 + Symfony 8 + Doctrine + PHPUnit sets
- CI: `--dry-run` (blocks on diff), local: auto-fix

## ECS

- PSR-12 + common + strict + cleanCode sets

## CI Pipeline (order)

```
1. ECS Check          — Coding standard (fastest check first)
2. PHPStan            — Static analysis + all 10 extensions
3. Rector --dry-run   — Outdated patterns?
4. PHPUnit Unit       — With path coverage
5. PHPUnit Integration — Against PostgreSQL (service container in CI)
6. Infection           — Mutation testing against unit suite
```

Steps 1–3 run in parallel (no DB needed). Steps 4–6 sequential.

## Architecture Tests (phpat)

Tests in `tests/Architecture/`, run via PHPStan (not PHPUnit):
- `LayerDependencyTest` — services must not depend on controllers
- `NamingConventionTest` — exceptions must be in Exception namespace

## Enforcement Matrix

| Rule | Tool | Threshold | Blocks CI? |
|---|---|---|---|
| Cognitive Complexity / method | `tomasvotruba/cognitive-complexity` | max 8 | Yes |
| Cognitive Complexity / class | `tomasvotruba/cognitive-complexity` | max 50 | Yes |
| Type Coverage | `tomasvotruba/type-coverage` | 100% | Yes |
| `declare(strict_types=1)` | `tomasvotruba/type-coverage` | 100% | Yes |
| Layer Dependencies | `phpat/phpat` | architecture test | Yes |
| Naming Conventions | `phpat/phpat` + `shipmonk` | architecture test | Yes |
| Strict comparisons | `phpstan-strict-rules` | strict | Yes |
| Deprecated code | `phpstan-deprecation-rules` | 0 | Yes |
| Debug functions | `shipmonk` (`forbidCustomFunctions`) | 0 | Yes |
| `DateTime` forbidden | `shipmonk` (`forbidCustomFunctions`) | 0 | Yes |
| PHPStan level | `phpstan/phpstan` | max | Yes |
| Coding standard | `symplify/easy-coding-standard` | PSR-12 + strict | Yes |
| Code modernity | `rector/rector` | PHP 8.4 + Symfony 8 | Yes (dry-run) |
| Path Coverage | PHPUnit 13 + PCOV | >= 80% | Yes |
| Mutation Score | `infection/infection` | MSI >= 80% | Yes |
| Covered Code MSI | `infection/infection` | >= 90% | Yes |
