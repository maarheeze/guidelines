# Architecture

Where a concept, a rule and a file live, and the shape of what crosses between
classes.

## Where a concept lives

- When you are about to add a method: you MUST first name the concept it is
  about and check that this class is that concept. When the class's one-sentence
  description does not already cover it, the method MUST go elsewhere and be
  called from here. Why: the pull is always that the caller already has the data
  at hand; giving in is how a service becomes a junk drawer.
- When describing a class needs an "and": it MUST be split into two. Many small
  classes SHOULD be preferred over few capable ones.
- When you are about to write a rule, such as a constant, a lookup table, a
  threshold or a condition: you MUST first search for it. Why: "does this concept
  already have a home?" is the question that prevents the duplication, not a
  later refactor.
- A rule MUST live in one named class and be referenced from everywhere else. A
  second copy is a bug, also when both copies are currently correct.
- When a second class needs a private const: the const MUST move to a class that
  owns that one rule, instead of widening its visibility. A ten-line constant
  holder is the right size.
- When you are about to fix a bug: it MUST be fixed where the concept lives, not
  where the symptom showed up, such as an N+1 on the relation instead of in the
  caller, or shared markup in the component instead of in the second template.

## Where a file lives

When you are about to create a file or folder:

- You MUST first name what it is. Its name and location MUST say that, not where
  it was first needed: a generic building block MUST NOT be named after the one
  page that uses it.
- Folders and namespaces MUST group by concept or by area of the application.
  Views and the classes behind them MUST use the same grouping, so one is found
  from the other.
- Something generic MUST live in a shared place under a generic name, also while
  only one area uses it. Something specific MUST live with the area it belongs
  to.
- When a folder's name does not describe the file: the folder MUST be split or
  dissolved instead of adding the file to it. Why: a folder its name cannot
  describe becomes the place for whatever has no home.

Why: a name that does not say what something is will not be found when it is
needed, and gets built a second time.

## A shaped array in a signature is a missing type

When you are about to write a shaped array type in a signature, such as
`@param array<string, int>` or `@return array<int, ?Uuid>`:

- An array that crosses a class boundary MUST become a type. Why: it is a domain
  concept travelling as a primitive. Every class that receives it grows its own
  query methods over it, and each one is a copy of a rule; a class that never
  holds the array cannot write the second copy.
- A private array that never leaves its class MAY stay an array. The line is the
  signature, not the array.
- A static array used as a cache SHOULD stay an array. Why: PHP's value semantics
  stop a caller mutating shared reference data; a collection returned from it
  would hand out the live object.
- A settings array or config blob MUST NOT be in a signature. JSON at rest is
  fine.

## Absence must not be a side-channel

When you are about to make a value nullable, give it a default or guard it:

- A value's type MUST say what that value is, and MUST NOT also answer a second
  question. Why: the moment `?Money` means both "the price" and "whether this is
  listed", the second meaning is invisible and unchecked.
- A default MUST NOT stand in for "not set yet", such as `= 0` on a price or
  `= 1970` on a timestamp. A typed property without a default throws when read
  early, which is the loud failure.
- What is actually absent MUST get a name and a type of its own.
- A nullable parameter MAY stay when the null is a fact about the domain. When it
  is the caller's state arriving, such as "nothing picked yet", the emptiness
  MUST stay where it arises and the method MUST be passed the value it needs.
- A guard MUST NOT be written for a state no caller can produce. If no caller can
  reach it, there is nothing to guard and nothing to test.
- A guard that only exists to undo an encoding, such as an
  `Assert::isInstanceOf()` on a value that was never null, MUST be removed by
  fixing the encoding.

## Casts

When you are about to cast a value:

- A cast MUST only be a boundary conversion: a database column read back, an
  array key PHP itself made a string, a native function's return. Anywhere else
  the property or parameter is typed wrong, and the type MUST be fixed instead.
- A value MUST NOT be stringified on the way in and cast back on the way out.
  The property type is wrong and MUST be fixed.
- Where validation guarantees a type the analyser cannot see, it MUST be
  asserted, not cast to keep the analyser quiet.
- A test MUST NOT cast a value it just built; the value MUST be built in the
  right type.

## Dependencies

When you are about to reach for something the class was not handed:

- A global function call MUST resolve to a function PHP itself defines. Why:
  every other one is somebody's wrapper over something it does not name, such as
  the container, the clock or the current request. This is a concept, not a list
  of banned names: a list is always one name short.
- A static call that resolves through the container MUST NOT be used either. It
  is the same defect in another spelling: banning `config()` while allowing
  `Config::get()` bans the spelling, not the practice.
- A class without a constructor MUST still inject. Framework hooks invoked
  through the container resolve their typed parameters, such as Livewire's
  `mount()`, `boot()` and `render()`, or a service provider's `boot()`. You MUST
  check before believing "injection is not available here".
- A dependency needed outside those methods MUST be assigned to a property in
  the hook that runs on every request.
- Anything that can vary MUST be injected, such as the clock through
  `Psr\Clock\ClockInterface`, randomness and the request. Why: a test then
  injects a version that does not vary.

## Parameters

When you are about to add a parameter:

- It MUST NOT have a default value. Why: a default is a decision made once, in
  the signature, for callers who have not thought about it, and it hides the
  moment a new input appears.
- It MUST NOT be a boolean. Why: `calculate($x, 9, 4, 0, false, false)` says
  nothing at the call site, and two adjacent flags swap without the type system
  noticing.
- A flag that selects between two behaviours MUST become separate methods,
  unless one branch is trivial; then the exemption MUST be in the input.
- Several flags that are part of one subject MUST become a value object with
  named fields, whose constructor refuses the invalid combinations.
- An enum SHOULD replace a boolean whenever the two states have names worth
  reading.
- A parameter every call site fills with the same value MUST move inside, and
  the method MUST be named after it.
- A caller MUST NOT have to fabricate a value only to satisfy the signature, such
  as a zeroed copy of its own state or an empty collection meaning "all of them".
  The intent MUST get a name.

## Layers

- When you are about to write logic in a transport, anything that exists because
  the outside world is talking to us, such as a controller, a Livewire
  component, a template or a client component: it MAY ask for a rule and MUST
  NOT hold one.
- A transport MUST ask one question and render the answer, and MUST NOT combine
  two. Why: the order and the short-circuiting of two legitimate calls is a
  business rule, and an `if` between them writes that rule into the transport.
- When a screen needs two answers put together: the combination MUST be named as
  a concept, given a home, and asked instead.
- A screen MUST be handed the answer to the question it asks, not "the data this
  screen needs". Why: a bag of data is an invitation to recombine.
- When you are about to show an amount of money that is later confirmed: it MUST
  be captured server-side when it is shown, and the command MUST record that
  captured figure, never recompute it at confirm. Why: every figure is derived
  from state someone else can change while the screen is open.
- Where the basis moving makes the quote wrong, the flow MUST refuse. Where a
  stale quote could overdraw something, the guard MUST live at the boundary that
  owns the limit.
- When you are about to write a calculator: it MUST be pure. The same inputs
  return the same answer, with no container, clock, database or randomness.

## Design principles

- When you are about to choose between two ways to write the same code: explicit
  and readable SHOULD be preferred over clever and compact, and composition
  SHOULD be preferred over inheritance.
- When code is no longer called: it MUST be removed.
- When you are about to add configuration, a strategy interface or a
  parameterised formula: it MUST NOT be built until a second real case requires
  it. Why: open to extension is a property of where code lives, not a feature to
  implement in advance.

## Method overrides

When you are about to override a method: its signature MUST match the parent's
exactly, including nullable types and default values. This overrides the rules on
`mixed` and on default values, which a framework contract can impose.

## Code formatting

When you are about to write a constructor or a chain of calls:

- Each constructor parameter MUST be on its own line, with a trailing comma.
- A chain of 1 or 2 calls MUST stay on one line. A chain of 3 or more MUST have
  each call on its own line.

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

- When you are about to fix `MultiLineCallEndsStatement` by moving one multi-line
  argument into a named method: every other multi-line argument of that chain
  MUST move as well. Why: a chain with one block extracted and one inline reads
  as if only one is allowed.

Example:
```php
// Not OK: only one block extracted
return parent::make($name)
    ->table(self::getTaxItemColumns())
    ->schema([
        TextEntry::make('quantity'),
        TextEntry::make('name'),
    ]);

// OK
return parent::make($name)
    ->table(self::getTaxItemColumns())
    ->schema(self::getTaxItemEntries());
```

## Properties

When you are about to declare a property:

- It MUST be readonly, unless something writes it after construction.
- When all constructor properties are readonly, the class MUST be declared
  `readonly`, and the properties MUST NOT repeat it.
