# PHP Guidelines

## Code Style & Standards

- Read and apply all rules from the project's code style configuration (e.g. `phpcs.xml`, `phpcs.xml.dist`) before writing any code
- Always end files with a single newline character (`\n`)
- Do not align array values — use a single space before `=>`
- Do not use named parameters unless needed

## Functions & Syntax

- Use explicit, verbose function syntax — avoid shorthand arrow functions (`fn() =>`)
- Never use `??` or `??=` — they rely on isset semantics and can silently swallow null or undefined values
- Prefer single quotes (`''`) over double quotes (`""`)
- Do not use FQDN for classes and functions — import them all
- Always sort imports alphabetically
- Never use abbreviations: write the full value in variables, methods etc.
- Enum cases are always in capitals with underscores (e.g. UserRole::ORGANISATION_ADMN)
- Prefer early returns instead of mutliple inline AND/OR checks  
- Do not assign unused variables
- A variable holding a stringified identifier must say so — `$playerIdAsString`, not `$player`, `$buyer` or `$holder`. A bare noun promises the entity; an id or array key is not the thing it identifies

## Control Structure Spacing & Readability

- Always add a blank line BEFORE if-statements (unless immediately after opening brace)
- Always add a blank line BEFORE return statements (unless at function start)
- In loops, add blank line before return/break statements
- In nested loops/conditions: blank line between distinct operations
- `foreach` directly followed by `if` is acceptable (when testing the loop item)

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
- Do not use redundant docblocks. A docblock is redundant if the information it contains is already explicit in the code (e.g. `@property` docblocks for constructor-promoted properties, `@param` docblocks for simple parameters where the type hint is sufficient, `@return` docblocks that merely restate what the return type declares). Only document what isn't obvious from the code itself.
- @var docblocks on properties must include the variable name: @var type $variableName (not `@var type` (missing variable) — always show what's being documented)

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
- Use nullable type syntax `?string` instead of union syntax `string|null` for clarity
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

- Exception messages must be static — no runtime variables interpolated into the message string
- If more context is needed for debugging, add a log message with optional context alongside the throw

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
- Consistent spacing around control structures