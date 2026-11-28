# PHP

What no sniff can check. What the `Maarheeze` phpcs standard already enforces is
not repeated here.

## Naming

When you are about to name a class, method, variable or enum case:

- You MUST name the concept and the class that owns it in one line before
  writing the body. Why: a name chosen once the body exists is taken from the
  body, and the body is mechanism.
- A method MUST be named after its own class and what it does with the class's
  content, never after one caller's reason for asking. Why: that name reads wrong
  at the second caller.
- A name MUST say what comes back, never how it is computed.
- A name MUST make sense as a sentence about the class without the body.
- A quantity word MUST have its noun: "none" or "empty" of what.
- A method that adds things up MUST be named as a total, not as an accessor.
- A method that filters and fills MUST NOT be named after the filtering alone.
- A verb MUST have its object, such as cleared, reset or updated of what. A
  question MUST have its subject, such as who "has access".
- A method returning a property, or a value built from one, MUST keep that
  property's name. Why: with two names for one value, the reader has to prove
  they are the same.
- A collection method MUST name the value that comes back, repeating the word
  also when the collection's name already contains it. Why: the call site shows
  the method, not the receiver's type.
- A generic verb, such as `calculate` or `resolve`, MAY only be used when the
  class name already says what comes out. Once the class returns something else,
  the method MUST get its own name; sibling classes sharing the verb is no reason
  to keep it.
- A variable MUST keep the full name of what produced it, qualifier included:
  `invoicesAwaitingApproval()` returns `$invoicesAwaitingApproval`, not
  `$invoices`.
- A bare plural, such as `$items`, `$data` or `$rows`, MUST NOT be used for
  anything less than all of them. Why: a bare plural reads as "all of them" and
  almost never is.
- A variable holding a stringified identifier MUST say so, such as
  `$userIdAsString` instead of `$user`. Why: a bare noun promises the entity.
- Abbreviations MUST NOT be used in variables, methods and classes.
- Arguments MUST be in the order the name reads: subject, then object, then the
  state it is asked against.
- Enum cases MUST be capitals with underscores, such as
  `UserRole::ORGANISATION_ADMIN`.
- Meaning MUST NOT be encoded in the order of enum cases, and an order MUST NOT
  be read off `cases()`. A sequence that matters MUST be a named list whose
  position is the rank, not a case-to-rank map. Why: a map states the sequence
  twice and lets the two halves be edited apart.
- A name that needs a comment to be understood MUST be replaced.

## Comments and docblocks

When you are about to write a comment or a docblock:

- A docblock MUST only carry types: `@param`, `@return`, `@template`,
  `@extends`, and `@var` with its variable name. Prose above a class, method or
  property MUST be removed by fixing what made it necessary.
- A docblock explaining what a parameter or an array position means MUST be
  replaced by a signature that says it, such as named keys, descriptive
  parameter names or a value object. Why: the signature is then the
  documentation, and cannot go stale.
- One line of prose MAY explain a constraint imposed from outside that cannot be
  fixed here, such as a framework handing a property over as a string, so the
  type is `int|string` and a reader "correcting" it breaks the code.
- A comment MUST NOT describe the state of the code, such as "temporary", "these
  fail until X lands" or "predictions, not measurements". That belongs in the
  issue tracker or the plan. Why: it is true the day it is written and misleading
  afterwards, and nobody reading a failure ever sees it.
- A template MUST NOT have comments.
- A method docblock MUST be multiline.

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

When you are about to build a string from more than one piece:

- It MUST be built with `sprintf()`, imported with `use function sprintf;`, and
  MUST NOT be built with `.`, however few the pieces and whatever they are.
  Interpolation is not the way out: the standard bans variables in
  double-quoted strings, and single quotes are the default.
- A number MUST use `%d`; text or a class string MUST use `%s`.

Why: the gain is largest where concatenation looks harmless, such as a dotted
path, a cast argument or a key prefix: the strings another layer has to parse
back.

When you are about to call a string function:

- Its family MUST be chosen by what the string is, not by the characters it
  happens to contain:
  * machine strings, such as HTTP methods, ISO codes, enum values, hex, UUIDs,
    cache keys and header names → `str*` (`strtoupper`, `strlen`, `substr`,
    `strpos`)
  * human text, such as names, titles, search terms and anything shown to a
    user → `mb_*` (`mb_strtoupper`, `mb_strlen`, `mb_substr`, `mb_stripos`)
  * counting or cutting visible content, such as character-count validation or
    truncating previews → `grapheme_*` (`grapheme_strlen`, `grapheme_substr`)
- Where bytes are the requirement, such as Content-Length, buffer sizes or
  hashing input, `strlen` MUST be used, never `mb_strlen`.
- `mb_strtoupper` and `mb_strtolower` MUST NOT be used on identifiers. Why:
  Unicode case mapping can change length (`ß` → `SS`) and cause collisions.
- Layers MUST NOT be mixed: a `strpos` byte offset MUST NOT feed `mb_substr`.
- `substr` MUST NOT be used on text that may be multibyte. Why: it can cut a
  character in half and produce invalid UTF-8.
- When unsure whether a string is an identifier or human text, it MUST be
  treated as human text.

## Statement grouping

When you are about to put a blank line between statements:

- A blank line MUST mark a change of subject, not a change of statement kind.
  Consecutive statements sharing a variable MUST be one paragraph. Why: grouping
  "all the assignments, then all the calls" is grouping by syntax; it looks tidy
  and reads badly, because the reader is following a subject.
- A group MUST NOT get its own break until it grows past one statement: two
  unrelated one-liners feeding the same next paragraph stay together.
- A statement touching two subjects MUST go with the one it assigns.
- Arrange, act and assert MUST be separate paragraphs, also when they share a
  subject.
- Each paragraph SHOULD be checked by reading the block aloud and naming what it
  is about. When two neighbouring paragraphs answer with the same noun, the
  break is wrong; when one paragraph needs two answers, a break is missing.

## Functions and syntax

When you are about to write a call or an expression:

- Named parameters MUST NOT be used unless needed.
- `??` and `??=` MUST NOT be used. Why: they rely on isset semantics and can
  silently swallow null or undefined values.
- `$data` and `$item` MUST NOT be used as names.

## Match statements and conditionals

When you are about to write a chain of conditions:

- Three or more if-elseif conditions MUST be a `match(true)`.
- One variable checked against several values MUST be a `match()` with string or
  enum keys.
- A sequence of `instanceof` checks MUST be a `match(true)` that delegates to one
  private handler per type: `handle<Type>()` for a visitor, `process<Scenario>()`
  for business logic.

## Method length and extraction

When a method grows:

- A public method SHOULD stay within 25 lines, a private method within 20.
- A method MUST be split when a loop body reaches 10 lines, when nesting reaches
  5 levels, or when it runs several sequential tasks, such as scan, process and
  cleanup.
- A private helper MUST be named by what it returns, not by what it processes:
  `findCallers()`, `expandFrontier()`, not `processNodes()`, `handleLoop()`.
- A private helper SHOULD return `null` for "skip this item" instead of using
  `continue`. A validation helper SHOULD return `true` or `false`.

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

## Type hints and docblocks

When you are about to narrow or declare a type:

- An inline `/** @var Type $var */` MUST NOT be used as a type assertion.
  Generics, such as `@extends ParentClass<ConcreteType>`, SHOULD narrow it
  through the type system; where they cannot,
  `Assert::isInstanceOf($var, Type::class)` from `webmozart/assert` MUST be used.
  When `webmozart/assert` is not installed, you MUST suggest adding it.
- `@template` and `@extends` or `@implements` generics MUST be added wherever
  they apply.
- A property type MUST NOT be narrower than the parent class or interface
  declares.

## Code organization

When you are about to add a constant, property or method: it MUST be sorted
alphabetically within its visibility group.

## Class and responsibility boundaries

When a class grows:

- A class whose description needs an "and" MUST be split; see `architecture.md`
  › Where a concept lives.
- A class MUST be split when it mixes state concerns, such as IO and schema,
  passes 500 lines across 10 or more public methods, or mixes abstraction
  levels.

## Static analysis

When you are about to write code, an assertion or an analyser tag:

- Code MUST pass PHPStan at the level configured in `phpstan.neon`, max by
  default.
- An assertion MUST say what a value is, never what it is not:
  `Assert::isInstanceOf` over `Assert::notNull`.
- Analyser-specific docblock tags, such as `@phpstan-*` and `@psalm-*`, MUST NOT
  be used. When a suppression feels necessary, the type is wrong and MUST be
  fixed.

## Exceptions

When you are about to throw an exception:

- A custom exception MUST be thrown when the caller is expected to catch it and
  act; an SPL exception MUST be thrown when it signals a bug nobody should catch.
- A bug MUST use the SPL type that says which kind: `InvalidArgumentException`
  for a bad argument, `LogicException` for an unreachable state.
  `RuntimeException` MUST NOT be used for a bug. Why: it erases that distinction.
- Custom exceptions MUST be grouped under one abstract base per domain.
- A custom exception MUST be named after the rule violated, not the class that
  threw it: `NotEnoughCreditRemaining`, not `AccountException`.
- Its message MUST be static, with no runtime values interpolated. Context MUST
  be carried as typed constructor properties, and logged with context when more
  is needed for debugging.
- A test MUST assert the exception class, never the message text.

## Value objects

When you are about to accept, compare or return a primitive:

- A string that needs validating, such as a uuid, an email address, money or an
  identifier, MUST be a value object.
- It MUST be converted at the earliest boundary, such as an Eloquent cast,
  request validation or a constructor, so the raw string never leaks past it.
- A comparison MUST use the value object's methods, never its underlying string.
- A count MUST NOT be returned as a signed difference; it MUST be two
  non-negative values, each named for what it counts. Why: a signed difference
  makes every caller branch on the sign.
- Domain state MUST travel as a named collection, not as an array of models.
