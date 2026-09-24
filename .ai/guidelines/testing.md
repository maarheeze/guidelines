# Testing Guidelines

## Before writing the test

- Name the decision the class under test makes, and ask whether this test would
  fail if that decision were wrong. If not, the test is aimed somewhere else
- Never test the framework. If a relation, a cast, a route binding or the
  container is what makes the assertion pass, the assertion belongs to the
  framework's own suite
- Name the caller that produces the state being tested. If there isn't one there
  is no test to write — `architecture.md` § Absence must not be a side-channel
- Do not assert a constant against a copy of itself. Test what the code *does*
  with the reference data; the constant is already the specification
- Pick the level by isolation: exercisable with no framework, container or I/O →
  unit test; needs the framework, the database or the container → feature test
  using a factory
- Prefer feature tests. Unit tests are for what is harder to cover through one
- Every production class has its own test

## Test structure

- A test class has no private helper methods. Not one
- Every test reads top to bottom on its own — arrange, act, assert — with nothing
  to jump to. A private helper hides part of the setup behind a name and drifts
  as tests are added around it
- Inline the tempting ones too: a wrapper around a timestamp, a wrapper around a
  container resolve, a loop that collects values for an assertion
- Repetition is not what justifies a helper. Two tests that stop sharing one are
  two tests that can change independently
- Do not use `setUp()` to build subjects or state. Shared abstract base classes
  are the exception
- Build each test's arrange block inline; create only what that test needs
- Never share a fixture holding pre-built domain state across tests — no
  `InteractsWith…` trait, no `…State` DTO returned by a helper and reused
- Shared *fixture classes* with their own names (a scenario builder, a fake
  factory, assertion traits) are a different thing and stay
- One behaviour per test. If the name needs an "and", or the body asserts both
  that something holds and that it does not, split it. Several assertions are
  fine only when they describe one outcome
- Never write try/catch in a test — use `$this->expectException()`
- Assign the subject of a boolean assertion to a named variable when its argument
  is itself a call with arguments: the assertion should read "x is false"

## Never hide the call under test

- The class the file is named after, and the method being exercised, appear
  literally in every test body, every time. Repetition here is the test
- The tell: does the helper's body name the class the file is named after? Then
  inline it, whatever else it appears to do and however many call sites it has
- Resolve the subject on its own line, into a local named after it. Do not chain
  the call off the container resolve
- A service the test merely arranges or reads with is different: resolve it in a
  shared fixture, and have that fixture return the answer, not the service

## Test data

- Fake any value the test does not read. Follow the value: if no assertion
  depends on it, it is faked. A literal nothing reads is a claim the test never
  makes, and the reader has to trace the code to discover it was decorative
- Pin a value only when the assertion would not hold for any other one. Ask:
  would this still be true for a different input?
- Where only *distinctness* matters, ask the fake for two different values rather
  than pinning two names
- The exception is a value that is a **rule** rather than an input — zero meaning
  "nothing is owed" is an assertion about the domain and stays
- A fixture method takes only what the test varies — `architecture.md`
  § Parameters

## Resolving

- A feature test uses `$this->app`, never `app()`. It is typed, and it says which
  container is meant
- A unit test resolves nothing. A unit test that needs the container is a feature
  test wearing the wrong base class
- `fake()` is the one that does not look like resolving: it calls `app()`, so a
  unit test using it binds into whatever container the last feature test left
- Never manipulate the global clock — no `freezeTime()`, `travelTo()`,
  `Carbon::setTestNow()`. They make *every* `now()` in the run lie
- Bind the fixed clock into the container instead (`architecture.md`
  § Dependencies), so only the thing under test sees it
- Most tests reaching for a frozen clock are pinning time so two independent
  calculations agree. Assert the relationship instead — read the figure the
  subject offered and assert the recorded value is *that* one

## Never add public API for a test

- A method or property no production code calls is dead API the next reader has
  to assume something depends on
- Assert through the contract the application actually uses
- If the contract is awkward to assert against, that is a fact about the design,
  not a reason to widen it

## Asserting persisted state

- Assert with `assertDatabaseHas(Model::class, [...])` — pass the model class, not
  a table-name string — rather than re-querying and asserting properties
- Only load a model when the test needs it to act, never just to read columns
- Anything querying the database names the scope it queries. A key that is unique
  only within a parent (a number unique per game, a position unique per order) is
  matched together with that parent's id, or the assertion silently hits whichever
  row came first
- Take the id, not the whole fixture object: it is the actual scope key and it
  matches the column
- A query with no subject is the worst form — a fixture reaching
  `Model::query()->firstOrFail()` leaves no call site saying what it asserted
- Where the test genuinely creates the only row, assert with `sole()`, not
  `firstOrFail()`: `sole()` fails if a second appears

## Component and view tests

- A component test asserts the data the component handed its view, or its public
  properties — typed and exact — not the text the page rendered
- Assert only what *this* component decided. That a price is 48 belongs to the
  class that computed it, whether restated as text or as view data
- A component whose job is mapping input onto one command asserts the command it
  recorded, the events it dispatched and the errors it rendered — never the
  projection that follows, which is the other class's test
- A dispatch assertion alone holds no matter which arguments reached the command.
  Assert the arguments
- A test name claiming two things is the tell that it reached past its subject
- If a test must assert text, use `assertSeeText()` / `assertDontSeeText()`.
  `assertSee()` is a substring match over the whole response including attributes,
  so a short numeric assertion matches against uuids nobody is looking at — it
  fails intermittently in one direction and passes on nothing in the other
- Assert a composite the view renders as one line (an id next to its name)
  rather than a bare number a stray attribute could satisfy
- Do not assert the absence of a value the positive assertion already covers

## Layers

| Layer | Owns |
|---|---|
| unit | the values — the exhaustive mapping of inputs to outputs |
| feature | one class, one command |
| story / journey | that the parts agree |

- The exhaustive table belongs to the lowest layer that can prove it, and no
  layer above restates it
- A literal above that layer is not automatically wrong. Ask what asserting it
  means: "the value is 35" is a copy of the table and goes; "given this state,
  the answer to this question is 35" keeps the state as the subject
- The tell is whether the setup could change without the number changing. If the
  setup is incidental, the number is the subject and belongs to the lower suite
- A story asserts that two parts of the system agree about a quantity, never what
  the quantity is: conservation, distribution, reset. Those hold at any number and
  no unit test can see them
- A story never names storage — no `assertDatabase*`, no model, table or column.
  Moves go through a scenario object that decides nothing: it never computes an
  amount, never branches on a rule, never chooses who acts
- Guards and plumbing in that object are fine. The line is whether removing the
  branch would change what the system does or only break the call
- A story is two or more things happening to something that already exists. One
  command, however much setup precedes it, is a feature test. Refusals are feature
  tests whatever they count
- The sharper test: would the assertion still be interesting if the earlier steps
  had been arranged some other way? If yes, they were setup
- Do not let the two layers share one arrange object. If the story's object
  exposes the feature suite's shortcuts, the one thing a story may never do
  becomes the handiest method on it

## Naming & layout

- PHPUnit test method names are camelCase (`testReturnsNullWhenNoMatch`); Pest
  test names are snake_case
- Test folders mirror the application's: `app/Service/ExampleService.php` →
  `tests/Feature/Services/ExampleServiceTest.php`
- Use named routes, not hardcoded URLs

## Mocking

- Do not use `shouldReceive()` — without `times()` a missed call passes silently
- Do not mark a class `final` if it needs mocking

## Rules about the shape of the code go in an arch test

- A shape rule a tool can enforce goes in `tests/Arch` — `index.md` § A rule must
  be able to fail
- Know what it cannot see: a template is not an autoloaded class, so a helper
  call inside one passes every arch test
- Browser tests are only for what needs a real browser — a real client-side
  runtime, a real DOM patch, a real teardown. Everything else is cheaper as a
  feature test
- If the suite mixes runners, run the one that executes all of them. A runner that
  silently skips a suite makes a green run prove nothing
