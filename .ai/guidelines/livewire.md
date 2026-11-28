# Livewire and Alpine

These are the failures no PHP test can reach: the component test harness renders
markup without running the client runtime, so everything here stays green while
it is broken.

## A morph can empty Alpine's scope

When you are about to write an Alpine expression on an element inside a Livewire
component:

- It MUST NOT read the component's own state, such as through `x-text`,
  `x-show`, `x-bind` or any expression naming a property. Why: Livewire's morph
  calls `Alpine.cloneNode(from, to)` on every element it patches. That copies
  `_x_dataStack` onto the incoming node by reference and skips `x-data`, so both
  nodes share one scope, and tearing down the old element pops it. Anything
  evaluated against it afterwards resolves in an empty scope, and the error names
  the property, never the cause: `ReferenceError: foo is not defined`.
- State SHOULD be held in the `Alpine.data` factory's closure, which nothing
  resolves through the scope. The DOM MUST then be written from the closure, such
  as `this.$el.textContent = ...`, with the initial value rendered by the server.
- After any change to an Alpine component inside a morphed tree, the browser
  console MUST be read. Why: a throwing bug is catchable in a browser test; a
  silent one, such as a timer outliving its element or a listener never removed,
  is not.

## Browser-set attributes need `wire:ignore.self`

When an element inside a Livewire component carries an attribute the browser
sets, such as `open` on a `<dialog>` opened with `showModal()`, `aria-expanded`
toggled by Alpine, or a scroll or drag state:

- The element MUST have `wire:ignore.self`. Plain `wire:ignore` MUST NOT be used
  for this, because it freezes the children too. Why: the morph patches an
  element's attributes from the freshly rendered HTML and removes any the server
  did not send. The symptom is never an error: the UI silently reverts
  mid-interaction, and it reads as "the buttons do nothing".
- The opener MUST be guarded too, such as
  `x-init="$el.open || $el.showModal()"`. Why: `showModal()` on an already-open
  dialog throws `InvalidStateError`.

## Browser tests

When you are about to write a browser test:

- It MUST drive the UI and assert what the page shows. It MUST NOT run a custom
  page script, such as replacing the scheduler or switching off the mutation
  observer. Why: that asserts against a browser nobody has, and only an edit to
  the code it mirrors can turn it red.
- Where that cannot reach the bug, it MUST be left uncovered, and you MUST say
  so.
- A server-rendered branch MUST NOT be asserted with `assertSeeLivewire()`; the
  test MUST assert text only that branch renders. Why: it is a runtime macro the
  analyser cannot see.

## In a client language, the rule is also the review

When you are about to write code in the client language:

- It MUST only hold code whose bugs are visible, such as presentation, animation
  and "what is open". Rules, prices, money and eligibility MUST NOT be in it.
  Why: if nobody on the project reads the client language, no human enforces
  anything in that layer. A wrong amount renders as a number and stays wrong for
  months; a thing drawn in the wrong place is wrong on screen immediately.
- A line with arithmetic, or with a comparison that decides something, MUST move
  to the server. When evaluating a line needs an understanding of the domain, it
  is in the wrong layer.
