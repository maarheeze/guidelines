# PHP Guidelines

What the `Maarheeze` phpcs standard already enforces is not repeated here. This
file is what no sniff can check.

## Functions & Syntax

- Do not use named parameters unless needed
- Never use `??` or `??=` — they rely on isset semantics and can silently swallow null or undefined values
- Never use abbreviations: write the full value in variables, methods etc.
- Enum cases are always in capitals with underscores (e.g. UserRole::ORGANISATION_ADMN)
- A variable holding a stringified identifier must say so — `$playerIdAsString`, not `$player`, `$buyer` or `$holder`. A bare noun promises the entity; an id or array key is not the thing it identifies
- Never use names like `$data` or `$item` — use clear names that show intent

## Match Statements & Conditionals

- Use `match(true)` instead of if-elseif chains when you have 3+ conditions checking expressions
- Use `match()` with string/enum keys when checking a single variable against multiple values
- For instanceof checks in sequences (e.g., visitor pattern), delegate each case to a private handler method
  - Name pattern: `handle<Type>()` for visitor pattern, `process<Scenario>()` for business logic
  - Keeps main method short (~5 lines) and logic focused

## Method Length & Extraction

- Public methods: soft limit of 25 lines; extract if exceeding with multiple responsibilities
- Private methods: soft limit of 20 lines; prioritize clarity over brevity
- Extract methods when:
  - Loop body is 10+ lines: extract to private method returning value or null
  - Nested blocks are 5+ levels deep: extract intermediate logic to helper
  - Multiple sequential tasks in one method: one method per task (scan → process → cleanup)
- Return `null` from private helper methods for "skip this item" control flow

## Data Structure Naming

- Name private helper methods by what they return/do, not what they process:
  - ✅ `findCallers()`, `expandFrontier()`, `createChunk()` — clear intent
  - ❌ `processNodes()`, `handleLoop()` — unclear what changes
- This makes the main method read like business logic, not mechanics

## Private Method Returns for Control Flow

- Return `null` instead of `continue` in loop helpers (cleaner at call site)
- Return `true`/`false` for validation helpers
- Return value for constructors/transformers
- Prefer specific return types over mixed returns

Example:
```php
foreach ($items as $item) {
    $result = $this->processItem($item);  // can be null
    if ($result !== null) {
        $results[] = $result;
    }
}

private function processItem($item): ?Type {
    if (!$this->validate($item)) return null;
    return $this->transform($item);
}
```

## Type Hints & Docblocks

- Never use `/** @var Type $var */` inline docblocks as type assertions
    - Prefer generics (e.g. `@extends ParentClass<ConcreteType>`) to narrow types through the type system
    - Fall back to `Assert::isInstanceOf($var, Type::class)` from `webmozart/assert` when generics are not available
    - If `webmozart/assert` is not installed, suggest adding it via `composer require webmozart/assert`
- Always add `@template` and `@extends`/`@implements` generics to interfaces and classes where applicable
- Do not add property types that are narrower than the parent class or interface declaration — this causes PHPStan errors on inheritance

## Docblock Formatting

- Method docblocks are always multiline

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

- Sort constants, properties, and methods alphabetically within each visibility group
- When a visitor's `enterNode()` or similar method has multiple sequential `if instanceof` checks, convert to a `match(true)` statement that delegates to private handler methods (one per node type)

## Class & Responsibility Boundaries

- **Single Responsibility Principle**: if you describe a class as "does X and Y", split it
- Extract when a class has:
  - Multiple state concerns (e.g., IO + schema → separate classes)
  - 500+ lines across 10+ public/protected methods
  - Mixed abstraction levels (low-level IO with high-level logic)
- Goal: each class should describe itself in one sentence
- When a public class method is 50+ lines or handles multiple concerns, extract:
  - Independent logic steps into separate private helper classes or methods
  - State management into dedicated classes (e.g., FileChangeAnalyzer handles change detection)
  - Schema/config into dedicated classes (e.g., SqliteSchema handles DDL)

## Static Analysis

- Always write code that passes PHPStan at the level configured in `phpstan.neon` or `phpstan.neon.dist`, defaulting to max level if no config is present
- Never assert what a value is not — assert what it actually is (e.g. prefer `Assert::isInstanceOf($var, Foo::class)` over `Assert::notNull($var)`)
- Do not use static-analyser-specific docblock tags — no `@phpstan-*`, `@psalm-*`, or similar; use standard PHPDoc tags (`@param`, `@return`, `@template`, etc.) only

## Exceptions

- Throw a custom exception when the caller is expected to catch it and act on it; throw an SPL exception when it signals a bug and nobody should catch it
- For bugs, pick the SPL type that says which kind: `InvalidArgumentException` for a bad argument, `LogicException` for a state that should be unreachable. `RuntimeException` for everything erases that distinction
- Group custom exceptions under one abstract base per domain, so a caller can catch the whole category in one place
- Name custom exceptions after the rule violated, not the method or class that threw (e.g. `NotEnoughSharesInBank`, not `MarketException`)
- Exception messages must be static — no runtime variables interpolated into the message string
- Custom exceptions carry context as typed constructor properties — this is how you add detail without breaking the static-message rule
- If more context is needed for debugging, add a log message with optional context alongside the throw
- Tests assert the exception class, never the message text

## Value objects

- Use or create valueObjects where applicable, instead of accepting a string where validation is required (e.g. uuid, email-address etc)
- Convert to the valueObject at the earliest boundary (e.g. an Eloquent cast, request validation, or the constructor), so the raw string never leaks past that boundary and the rest of the code always works with the valueObject
- Use the valueObject's comparison methods instead of comparing its underlying (string) value

## String Handling

- Prefer sprintf() over string concatenation with '.' when building strings with multiple variables or path components. This improves readability by separating the format from the values.
- Choose the string function family based on what the string *is*, not what characters it happens to contain:
  * **Machine strings** (HTTP methods, ISO codes, enum values, hex, UUIDs, cache keys, header names, anything defined by code or a spec) → `str*` functions (`strtoupper`, `strlen`, `substr`, `strpos`)
  * **Human text** (names, titles, search terms, anything that came from or is shown to a user) → `mb_*` functions (`mb_strtoupper`, `mb_strlen`, `mb_substr`, `mb_stripos`)
  * **Counting or cutting visible user content** (character-count validation, truncating previews, anything where emoji or combining marks may appear) → `grapheme_*` functions (`grapheme_strlen`, `grapheme_substr`)
- Use `strlen` when bytes are the actual requirement (Content-Length, buffer sizes, byte-based storage limits, hashing input) — never `mb_strlen` there
- Never use `mb_strtoupper`/`mb_strtolower` on identifiers — Unicode case mapping can change string length (`ß` → `SS`) and cause collisions
- Never mix layers: do not feed a `strpos` byte offset into `mb_substr` or vice versa
- Never use `substr` on text that may contain multibyte characters — it can cut a character in half and produce invalid UTF-8
- When unsure whether a string is an identifier or human text, treat it as human text and use `mb_*`

## Refactoring Checklist Before Testing

Before committing refactored code:
- No method longer than 35 lines without clear delegation pattern
- Each method has single responsibility (one reason to change)
- Loop bodies extracted if 10+ lines
- if-instanceof chains → match statements with handlers
- if-elseif chains (3+) → match statements
- No nested conditionals deeper than 2 levels
- Private helpers return values for control flow
- All files pass PHPStan at configured level
