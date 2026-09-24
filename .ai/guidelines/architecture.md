# Architecture Guidelines

## Where a concept lives

- Before adding a method, name the concept it is about and check that this class
  *is* that concept. If the class's one-sentence description does not already
  cover it, the method belongs elsewhere and is called from here
- The pull is always that the caller already has the data at hand. Giving in is
  how a service becomes a junk drawer
- If describing a class needs an "and", it is two classes. Prefer many small
  classes over few capable ones
- A rule — a constant, a lookup table, a threshold, a condition — lives in one
  named class and is referenced from everywhere else. A second copy is a bug even
  when both copies are currently correct
- A private const is not a home once a second class needs the same rule. Move it
  to a class that owns that one rule rather than widening visibility — a
  ten-line constant holder is the right size
- Before writing a rule anywhere, search for it. "Does this concept already have
  a home?" is the question that prevents the duplication, not a later refactor
- Fix a bug where the concept lives, not where the symptom showed up: an N+1 on
  the relation, not in the caller; shared markup in the component, not in the
  second template

## A shaped array in a signature is a missing type

- `@param array<string, int>` or `@return array<int, ?Uuid>` crossing a class
  boundary means a domain concept is travelling as a primitive. Give it a type
- Every class that receives such an array grows its own query methods over it,
  and each one is a copy of a rule. A class that never holds the array cannot
  write the second copy — a type enforces what a convention only asks
- The line is the signature, not the array. A private array that never leaves its
  class is fine and is not worth converting
- A static array used as a cache is deliberately an array: PHP's value semantics
  are what stop a caller mutating shared reference data. Returning a collection
  from it would hand out the live object
- Never put a settings array or config blob in a signature. JSON at rest is fine;
  a shaped array at a class boundary is not

## Absence must not be a side-channel

- A value's type says what that value is. It must never also answer a second
  question — the moment `?Money` means both "the price" and "whether this is
  listed", the second meaning is invisible and unchecked
- A default standing in for "not set yet" (`= 0` on a price, `= 1970` on a
  timestamp) is a placeholder wearing a valid value. A typed property with no
  default throws when read early, which is the loud failure
- The tell is a guard that exists only to undo the encoding — an
  `Assert::isInstanceOf()` on a value that was never null is a dead guard
- Ask what is actually absent and give *that* a name and a type
- A nullable parameter is usually the caller's state arriving. If the null is a
  fact about the domain, the parameter is honest; if it is "nothing picked yet",
  leave the emptiness where it arises and pass the value the method needs
- Never write a guard for a state no caller can produce. If no caller can reach
  it, there is nothing to guard and nothing to test

## Casts

- A cast is a boundary conversion: a database column read back, an array key PHP
  itself made a string, a native function's return. Everywhere else a cast is the
  tell that a property or parameter is typed wrong, and the fix is the type
- Two casts around one value — stringified on the way in, cast back on the way
  out — means the property type is wrong
- Where validation guarantees a type but the analyser cannot see it, assert it;
  do not cast to keep the analyser quiet
- A test that casts a value it just built is building it in the wrong type

## Dependencies

- A global function call must resolve to a function PHP itself defines. Every
  other one is somebody's wrapper over something it does not name — the
  container, the clock, the current request
- Do not read this as a list of banned names: a list is always one name short
- A static call that resolves through the container is the same defect in a
  different spelling. Banning `config()` while allowing `Config::get()` bans the
  spelling, not the practice
- A class with no constructor still injects: framework hooks invoked through the
  container resolve their typed parameters (Livewire's `mount()`, `boot()` and
  `render()`, a service provider's `boot()`). "Injection is not available here"
  is almost always wrong — check before believing it
- A dependency needed outside those methods is assigned to a property in the hook
  that runs on every request
- Anything that can vary is injected: the clock through `Psr\Clock\ClockInterface`,
  randomness, the request. A test then injects a version that does not vary

## Parameters

- No default parameter values. A default is a decision made once, in the
  signature, for callers who have not thought about it, and it hides the moment a
  new input appears
- No boolean parameters. `calculate($x, 9, 4, 0, false, false)` says nothing at
  the call site and two adjacent flags swap without the type system noticing
- Replace a flag with separate methods when it selects between two behaviours —
  unless one branch is trivial, in which case the exemption belongs in the input
- Replace several flags with a value object with named fields when they are part
  of one subject, and let its constructor refuse the invalid combinations
- An enum beats a boolean whenever the two states have names worth reading
- A parameter every call site fills with the same value is not a parameter. Move
  it inside and name the method after it
- Do not make a caller fabricate a value only to satisfy a signature — a zeroed
  copy of its own state, an empty collection meaning "all of them". The intent
  deserves a name

## Layers

- A transport is anything that exists because the outside world is talking to us:
  a controller, a Livewire component, a template, a client component. It may
  *ask* for a rule. It may not hold one
- A transport asks one question and renders the answer. It never combines two —
  the order and the short-circuiting of two legitimate calls *is* a business rule,
  and an `if` between them writes that rule into the transport
- If a screen needs two answers put together, the combination is a concept with
  no home yet. Name it, give it one, and ask that instead
- What a screen is handed is the answer to the question it asks, not "the data
  this screen needs". A bag of data is an invitation to recombine
- Whatever a screen quotes as money is captured server-side when it is shown, and
  the command records that captured figure. Never recompute at confirm — every
  figure is derived from state someone else can change while the screen is open
- Capture is only half of it: where the basis moving makes the quote wrong, the
  flow refuses, and where a stale quote could overdraw something, the guard lives
  at the boundary that owns the limit
- Keep calculators pure: given the same inputs they return the same answer, with
  no container, clock, database or randomness

## Design Principles

- Prefer explicit over clever — readable code over compact code
- Prefer composition over inheritance
- Never leave dead code — use it or remove it
- Do not build for variants that do not exist yet: no configuration, strategy
  interfaces or parameterised formulas until a second real case requires them.
  Open to extension is a property of where code lives, not a feature to implement
  in advance

## Method Overrides

- Always match the parent method signature exactly when overriding, including
  nullable types and default values — this outranks the house rules on `mixed`
  and on default values, which a framework contract can impose

## Code Formatting

- Constructor parameters are always each on their own line, with a trailing comma
- Chain length determines formatting:
    - 1–2 chained calls stay on one line
    - 3 or more chained calls each go on their own line

Example:
```php
// OK
$result = $query->where('active', true)->first();

// OK
$result = $query
    ->where('active', true)
    ->orderBy('created_at')
    ->first();
```

## Properties

- Make properties readonly if possible
- If all constructor properties are readonly (or the class is `readonly`), declare
  the class as `readonly` and omit `readonly` from individual properties
