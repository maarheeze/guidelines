# Livewire & Alpine Guidelines

These are the failures no PHP test can reach: the component test harness renders
markup without running the client runtime, so everything here stays green while
it is broken.

## A morph can empty Alpine's scope

- Livewire's morph calls `Alpine.cloneNode(from, to)` on every element it patches.
  That copies `_x_dataStack` onto the incoming node **by reference** and skips
  `x-data`, so both nodes share one scope — and tearing down the old element pops
  that shared stack
- Anything evaluated against it afterwards resolves in an empty scope, and the
  error names the property, never the cause: `ReferenceError: foo is not defined`
- So an Alpine expression that reads the component's own state — `x-text`,
  `x-show`, `x-bind`, any expression naming a property — is not safe on an element
  inside a Livewire component
- Values held in the `Alpine.data` factory's **closure** are safe, because nothing
  resolves them through the scope. Write the DOM from the closure
  (`this.$el.textContent = ...`) and let the server render the initial value
- After any change to an Alpine component inside a morphed tree, read the browser
  console. A throwing bug is catchable in a browser test; a silent one — a timer
  outliving its element, a listener never removed — is not

## Browser-set attributes need `wire:ignore.self`

- The morph patches an element's attributes from the freshly rendered HTML and
  removes any the server did not send
- So any attribute the *browser* set — `open` on a `<dialog>` opened with
  `showModal()`, `aria-expanded` toggled by Alpine, a scroll or drag state — is
  wiped on the next re-render
- The symptom is never an error: the UI silently reverts mid-interaction, and it
  reads as "the buttons do nothing"
- `wire:ignore.self` leaves the element's own attributes alone while still
  morphing its children. Plain `wire:ignore` would freeze the children too
- Guard the opener too: `showModal()` on an already-open dialog throws
  `InvalidStateError` — `x-init="$el.open || $el.showModal()"`

## Browser tests

- Drive the UI and assert what the page shows. No custom page script inside a
  test — replacing the scheduler or switching off the mutation observer asserts
  against a browser nobody has, and only an edit to the code it mirrors can turn
  it red
- Where that cannot reach the bug, leave it uncovered and say so
- Never assert a server-rendered branch with `assertSeeLivewire()` — it is a
  runtime macro the analyser cannot see. Assert text only that branch renders

## In a client language, the rule is also the review

- If nobody on the project reads the client language, no human enforces anything
  in that layer
- The client may only hold code whose bugs are visible. A wrong amount renders as
  a number and stays wrong for months; a thing drawn in the wrong place is wrong
  on screen immediately
- Presentation, animation and "what is open" belong there. Rules, prices, money
  and eligibility do not
- Checkable without knowing the framework: look for arithmetic, or a comparison
  that decides something. If evaluating a line needs an understanding of the
  domain, the line is in the wrong layer
