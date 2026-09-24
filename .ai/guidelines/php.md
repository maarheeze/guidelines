# PHP Guidelines

What the `Maarheeze` phpcs standard already enforces is not repeated here. This
file is what no sniff can check.

## Naming

- Name the concept and the class that owns it in one line *before* writing the
  body. A name chosen once the body exists is taken from the body, and the body
  is mechanism
- Name a method after its own class and what it does with the class's content,
  never after one caller's reason for asking — that name reads wrong at the
  second caller
- The name says *what* comes back, never *how* it is computed
- Say the name out loud as a sentence about the class. If the sentence needs the
  body to make sense, the name is wrong
- A quantity word needs its noun: "none" or "empty" of *what*
- A method that adds things up is named as a total, not as an accessor
- A method that filters *and* fills cannot be named after the filtering alone
- A verb needs its object (cleared, reset, updated — of what), a question needs
  its subject ("has access" — who has it)
- A method returning a property, or a value built from one, keeps that property's
  name. Two names for one value means the reader has to prove they are the same
- A collection method names the value that comes back, repeating the word even
  when the collection's name already contains it — the call site shows the
  method, not the receiver's type
- A generic verb (`calculate`, `resolve`) is allowed only when the class name has
  already said what comes out. Once the class returns something else, the method
  needs its own name. Sibling classes sharing a verb is not a reason to keep it
- A variable keeps the full name of what produced it. Never drop the qualifier —
  `invoicesAwaitingApproval()` returns `$invoicesAwaitingApproval`, not
  `$invoices`
- A bare plural reads as "all of them" and almost never is. `$items`, `$data`,
  `$rows` are the shapes this is broken in most often
- A variable holding a stringified identifier says so — `$userIdAsString`, not
  `$user`. A bare noun promises the entity
- Never use abbreviations; write the full word in variables, methods and classes
- Argument order follows the name: subject, then object, then the state it is
  asked against
- Enum cases are capitals with underscores (`UserRole::ORGANISATION_ADMIN`)
- Never encode meaning in the order of enum cases, and never read an order off
  `cases()`. A sequence that matters belongs to a named list whose position is
  the rank — not a case-to-rank map, which states the sequence twice and lets the
  two halves be edited apart
- A name that needs a comment to be understood is the wrong name

## Comments & Docblocks

- A docblock carries types: `@param`, `@return`, `@template`, `@extends`, `@var`
  with its variable name. Prose above a class, method or property is removed by
  fixing what made it necessary
- A long docblock explaining what a parameter or an array position means is the
  tell. Fix the signature — named keys, descriptive parameter names, a value
  object — so the signature is the documentation and cannot go stale
- One exception, one line: a constraint imposed from outside that cannot be fixed
  here (a framework hands a property over as a string, so the type is `int|string`
  and a reader "correcting" it breaks the code)
- Never write a comment about the state of the code — "temporary", "these fail
  until X lands", "predictions, not measurements". It is true the day it is
  written and misleading afterwards, and nobody reading a failure ever sees it.
  That belongs in the issue tracker or the plan
- Do not add comments in templates
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

## Strings

- Never build a string with `.`, however few the pieces and whatever they are.
  Every string built from more than one piece is `sprintf()`, imported with
  `use function sprintf;`
- `%d` where the value is a number, `%s` where it is text or a class string
- Interpolation is not the way out — the standard bans variables in double-quoted
  strings, and single quotes are the default
- The gain is largest where concatenation looks harmless: a dotted path, a cast
  argument, a key prefix — the strings another layer has to parse back
- Choose the string function family by what the string *is*, not by what
  characters it happens to contain:
  * **Machine strings** (HTTP methods, ISO codes, enum values, hex, UUIDs, cache
    keys, header names) → `str*` (`strtoupper`, `strlen`, `substr`, `strpos`)
  * **Human text** (names, titles, search terms, anything shown to a user) →
    `mb_*` (`mb_strtoupper`, `mb_strlen`, `mb_substr`, `mb_stripos`)
  * **Counting or cutting visible content** (character-count validation,
    truncating previews) → `grapheme_*` (`grapheme_strlen`, `grapheme_substr`)
- Use `strlen` when bytes are the requirement (Content-Length, buffer sizes,
  hashing input) — never `mb_strlen` there
- Never use `mb_strtoupper`/`mb_strtolower` on identifiers — Unicode case mapping
  can change length (`ß` → `SS`) and cause collisions
- Never mix layers: a `strpos` byte offset must not feed `mb_substr`
- Never use `substr` on text that may be multibyte — it can cut a character in
  half and produce invalid UTF-8
- When unsure whether a string is an identifier or human text, treat it as human
  text and use `mb_*`

## Statement grouping

- A blank line marks a change of subject, not a change of statement kind.
  Consecutive statements sharing a variable are one paragraph
- Grouping "all the assignments, then all the calls" is grouping by syntax. It
  looks tidy and reads badly — the reader is following a subject
- A group only earns a break once it grows past one statement; two unrelated
  one-liners feeding the same next paragraph stay together
- A statement touching two subjects belongs to the one it assigns
- Arrange, act and assert are separate paragraphs even when they share a subject
- Read the block aloud and name what each paragraph is about. Two neighbouring
  paragraphs answering with the same noun means the break is wrong; one paragraph
  needing two answers means a break is missing

## Functions & Syntax

- Do not use named parameters unless needed
- Never use `??` or `??=` — they rely on isset semantics and can silently swallow
  null or undefined values
- Never use names like `$data` or `$item`

## Match Statements & Conditionals

- Use `match(true)` instead of if-elseif chains of 3+ conditions
- Use `match()` with string/enum keys when checking one variable against several
  values
- For a sequence of `instanceof` checks, `match(true)` delegating to one private
  handler per type — `handle<Type>()` for a visitor, `process<Scenario>()` for
  business logic

## Method Length & Extraction

- Public methods: soft limit of 25 lines. Private methods: 20
- Extract when a loop body reaches 10 lines, when nesting reaches 5 levels, or
  when one method runs several sequential tasks (scan → process → cleanup)
- Name a private helper by what it returns, not by what it processes:
  `findCallers()`, `expandFrontier()`, not `processNodes()`, `handleLoop()`
- Return `null` from a private helper for "skip this item" rather than
  `continue`; return `true`/`false` from a validation helper

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
    - Prefer generics (`@extends ParentClass<ConcreteType>`) to narrow through the
      type system
    - Fall back to `Assert::isInstanceOf($var, Type::class)` from
      `webmozart/assert` when generics are not available
    - If `webmozart/assert` is not installed, suggest adding it
- Always add `@template` and `@extends`/`@implements` generics where applicable
- Do not add property types narrower than the parent class or interface

## Code Organization

- Sort constants, properties and methods alphabetically within each visibility
  group

## Class & Responsibility Boundaries

- Splitting a class whose description needs an "and" is in `architecture.md`
  § Where a concept lives
- Extract when a class mixes state concerns (IO + schema), passes 500 lines
  across 10+ public methods, or mixes abstraction levels

## Static Analysis

- Always write code that passes PHPStan at the level configured in
  `phpstan.neon`, defaulting to max
- Never assert what a value is not — assert what it is (`Assert::isInstanceOf`
  over `Assert::notNull`)
- No static-analyser-specific docblock tags — no `@phpstan-*`, `@psalm-*`. If a
  suppression feels necessary, the type is wrong

## Exceptions

- Throw a custom exception when the caller is expected to catch it and act;
  throw an SPL exception when it signals a bug nobody should catch
- For bugs, pick the SPL type that says which kind: `InvalidArgumentException`
  for a bad argument, `LogicException` for an unreachable state.
  `RuntimeException` erases that distinction
- Group custom exceptions under one abstract base per domain
- Name a custom exception after the rule violated, not the class that threw it
  (`NotEnoughCreditRemaining`, not `AccountException`)
- Exception messages are static — no runtime variables interpolated
- Carry context as typed constructor properties; log with context if more is
  needed for debugging
- Tests assert the exception class, never the message text

## Value objects

- Create a value object instead of accepting a string that needs validating
  (uuid, email address, money, an identifier)
- Convert at the earliest boundary — an Eloquent cast, request validation, a
  constructor — so the raw string never leaks past it
- Use the value object's comparison methods, never its underlying string
- A count returned as a signed difference makes every caller branch on the sign.
  Return two non-negative values, each named for what it counts
- Domain state travels as a named collection, not as an array of models
