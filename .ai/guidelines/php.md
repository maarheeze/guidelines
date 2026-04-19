# PHP Guidelines

## Code Style & Standards

- Read and apply all rules from the project's code style configuration (e.g. `phpcs.xml`, `phpcs.xml.dist`) before writing any code
- Always end files with a single newline character (`\n`)
- Do not align array values — use a single space before `=>`

## Functions & Syntax

- Use explicit, verbose function syntax — avoid shorthand arrow functions (`fn() =>`)
- Never use `??` or `??=` — they rely on isset semantics and can silently swallow null or undefined values
- Prefer `sprintf()` over string interpolation for complex or repeated strings
- Prefer single quotes (`''`) over double quotes (`""`)
- Do not use FQDN for classes and functions — import them all
- Always sort imports alphabetically
- Never use abbreviations: write the full value in variables, methods etc.
- Enum cases are always in capitals with underscores (e.g. UserRole::ORGANISATION_ADMN)

## Type Hints & Docblocks

- Always typehint parameters and return types, including `void`
- Add docblocks for array shapes (e.g. `array<string, int>`)
- Never use `/** @var Type $var */` inline docblocks as type assertions
    - Prefer generics (e.g. `@extends ParentClass<ConcreteType>`) to narrow types through the type system
    - Fall back to `Assert::isInstanceOf($var, Type::class)` from `webmozart/assert` when generics are not available
    - If `webmozart/assert` is not installed, suggest adding it via `composer require webmozart/assert`
- Always add `@template` and `@extends`/`@implements` generics to interfaces and classes where applicable
- Type collection generics in docblocks (e.g. `@param Collection<int, User>`)
- Always specify iterable value types in docblocks (e.g. `array<string, string>` not `array`)
- Do not add property types that are narrower than the parent class or interface declaration — this causes PHPStan errors on inheritance

## Docblock Formatting

- Method docblocks are always multiline
- Property `@var` docblocks are always single-line
- Separate different type-groups (@template, @param, @return, etc.) with a blank line

Example:
```php
/**
 * @template T
 *
 * @param array<int, T> $items
 * @return Collection<int, T>
 */
public function collect(array $items): Collection
```

## Comments & Documentation

- Do not create "explaining" docblocks or comments — code should be self-documenting
- Do not add comments in (html) templates

## Code Organization

- Always add visibility and types to constants, properties, and methods
- Sort constants, properties, and methods by visibility in this order: public, protected, private — then alphabetically within each group

## Static Analysis

- Always write code that passes PHPStan at the level configured in `phpstan.neon` or `phpstan.neon.dist`, defaulting to max level if no config is present
- Never assert what a value is not — assert what it actually is (e.g. prefer `Assert::isInstanceOf($var, Foo::class)` over `Assert::notNull($var)`)
- Do not use static-analyser-specific docblock tags — no `@phpstan-*`, `@psalm-*`, or similar; use standard PHPDoc tags (`@param`, `@return`, `@template`, etc.) only

## Exceptions

- Exception messages must be static — no runtime variables interpolated into the message string
- If more context is needed for debugging, add a log message with optional context alongside the throw

## Value objects

- Use or create valueObjects where applicable, instead of accepting a string where valiation is required (e.g. uuid, email-address etc)
- Use valueObject comparison methods instead where possible, instead of comparing the (string) value from it