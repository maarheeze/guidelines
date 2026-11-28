# Testing

## Before writing the test

When you are about to write a test:

- You MUST name the decision the class under test makes. The test MUST fail if
  that decision were wrong; if it would not, it is aimed somewhere else.
- It MUST NOT test the framework. When a relation, a cast, a route binding or the
  container is what makes the assertion pass, the assertion belongs to the
  framework's own suite.
- You MUST name the caller that produces the state being tested. When there is
  none, there is no test to write; see `architecture.md` › Absence must not be a
  side-channel.
- It MUST NOT assert a constant against a copy of itself. It MUST test what the
  code does with the reference data; the constant is already the specification.
- Its level MUST follow from isolation: exercisable without the framework, the
  container or I/O is a unit test; needing the framework, the database or the
  container is a feature test using a factory.
- A feature test SHOULD be preferred. A unit test is for what is harder to cover
  through one.
- Every production class MUST have its own test.

## Test structure

When you are about to structure a test class or a test:

- A test class MUST NOT have private helper methods. Not one.
- Every test MUST read top to bottom on its own, arrange, act, assert, with
  nothing to jump to. That includes the tempting helpers, such as a wrapper
  around a timestamp, a wrapper around a container resolve, or a loop that
  collects values for an assertion. Why: a helper hides part of the setup behind
  a name and drifts as tests are added around it. Repetition does not justify
  one: two tests that stop sharing a helper can change independently.
- `setUp()` MUST NOT build subjects or state. A shared abstract base class is the
  exception.
- Each test MUST build its arrange block inline, creating only what that test
  needs.
- A fixture holding pre-built domain state MUST NOT be shared across tests, such
  as an `InteractsWith…` trait or a `…State` DTO returned by a helper and reused.
  A shared fixture class with its own name, such as a scenario builder, a fake
  factory or an assertion trait, MAY stay.
- A test MUST cover one behaviour. When its name needs an "and", or its body
  asserts both that something holds and that it does not, it MUST be split.
  Several assertions MAY describe one outcome.
- A test MUST NOT have a try/catch. In PHPUnit, `$this->expectException()` MUST
  be used; in Pest, `->throws()` MUST be chained on the test. Why:
  `expectException()` is protected, and an IDE flags calling it from the test
  closure.
- When the argument of a boolean assertion is itself a call with arguments, its
  subject MUST be assigned to a named variable first, so the assertion reads
  "x is false".

## Never hide the call under test

When you are about to call the subject of a test:

- The class the file is named after, and the method being exercised, MUST appear
  literally in every test body. Repetition here is the test.
- A helper whose body names the class the file is named after MUST be inlined,
  whatever else it appears to do and however many call sites it has.
- The subject MUST be resolved on its own line, into a local named after it, and
  MUST NOT be called off the container resolve in one chain.
- A service the test only arranges or reads with MAY be resolved in a shared
  fixture, and that fixture MUST return the answer, not the service.

## Test data

When you are about to give a test a value:

- A value no assertion depends on MUST be faked. Why: a literal nothing reads is
  a claim the test never makes, and the reader has to trace the code to discover
  it was decorative.
- A value MUST only be pinned when the assertion would not hold for any other
  one.
- Where only distinctness matters, the fake MUST be asked for two different
  values instead of pinning two names.
- A value that is a rule rather than an input MUST stay pinned, such as zero
  meaning "nothing is owed": that is an assertion about the domain.
- A fixture method MUST take only what the test varies; see `architecture.md` ›
  Parameters.

## Resolving

When you are about to resolve something or fix the time in a test:

- A feature test MUST use `$this->app`, never `app()`. Why: it is typed, and it
  says which container is meant.
- A unit test MUST NOT resolve anything. A unit test that needs the container
  MUST be a feature test.
- A unit test MUST NOT use `fake()`. Why: it does not look like resolving, but it
  calls `app()`, so it binds into whatever container the last feature test left.
- The global clock MUST NOT be manipulated, such as with `freezeTime()`,
  `travelTo()` or `Carbon::setTestNow()`. Why: they make every `now()` in the run
  lie. A fixed clock MUST be bound into the container instead, so only the thing
  under test sees it; see `architecture.md` › Dependencies.
- When time is pinned only so two independent calculations agree, the test
  SHOULD assert the relationship instead: read the figure the subject offered and
  assert the recorded value is that one.

## Never add public API for a test

When you are about to add a method or property that only a test calls: you MUST
NOT.

- The test MUST assert through the contract the application actually uses. Why:
  a method no production code calls is dead API the next reader has to assume
  something depends on.
- A contract that is awkward to assert against is a fact about the design, and
  MUST NOT be a reason to widen it.

## Asserting persisted state

When you are about to assert what was stored:

- It MUST be asserted with `assertDatabaseHas(Model::class, [...])`, passing the
  model class and not a table name, instead of re-querying and asserting
  properties.
- A model MUST only be loaded when the test needs it to act, never just to read
  columns.
- A query MUST name the scope it queries. A key unique only within a parent, such
  as a number unique per game or a position unique per order, MUST be matched
  together with that parent's id. Why: otherwise the assertion silently hits
  whichever row came first.
- The scope MUST be passed as the id, not the whole fixture object: the id is the
  scope key and matches the column.
- A query without a subject MUST NOT be used, such as a fixture reaching
  `Model::query()->firstOrFail()`. Why: no call site says what was asserted.
- Where the test creates the only row, it MUST assert with `sole()`, not
  `firstOrFail()`. Why: `sole()` fails when a second one appears.

## Component and view tests

When you are about to test a component or a view:

- It MUST assert the data the component handed its view, or its public
  properties, typed and exact, not the text the page rendered.
- It MUST only assert what this component decided. That a price is 48 belongs to
  the class that computed it, whether restated as text or as view data.
- A component whose job is mapping input onto one command MUST assert the
  command it recorded, the events it dispatched and the errors it rendered, and
  MUST NOT assert the projection that follows; that is the other class's test.
- A dispatch assertion MUST assert the arguments. Why: on its own it holds no
  matter which arguments reached the command.
- A test name MUST NOT claim two things. Why: that is the tell that the test
  reached past its subject.
- When a test must assert text, it MUST use `assertSeeText()` or
  `assertDontSeeText()`, never `assertSee()`. Why: `assertSee()` is a substring
  match over the whole response, attributes included, so a short number matches
  uuids nobody is looking at: it fails intermittently in one direction and passes
  on nothing in the other.
- It SHOULD assert a composite the view renders as one line, such as an id next
  to its name, instead of a bare number a stray attribute could satisfy.
- It MUST NOT assert the absence of a value the positive assertion already
  covers.

## Layers

| Layer | Owns |
|---|---|
| unit | the values — the exhaustive mapping of inputs to outputs |
| feature | one class, one command |
| story / journey | that the parts agree |

When you are about to decide which layer asserts something:

- The exhaustive table MUST belong to the lowest layer that can prove it, and
  MUST NOT be restated by a layer above.
- A literal above that layer MUST be checked for what asserting it means: "the
  value is 35" is a copy of the table and goes; "given this state, the answer to
  this question is 35" keeps the state as the subject. When the setup could
  change without the number changing, the number is the subject and belongs to
  the lower suite.
- A story MUST assert that two parts of the system agree about a quantity, such
  as conservation, distribution or reset, never what the quantity is. Why: those
  hold at any number, and no unit test can see them.
- A story MUST NOT name storage: no `assertDatabase*`, no model, table or column.
  Its moves MUST go through a scenario object that decides nothing: it never
  computes an amount, branches on a rule or chooses who acts. Guards and plumbing
  in that object MAY stay; the line is whether removing the branch would change
  what the system does or only break the call.
- A story MUST be two or more things happening to something that already exists.
  One command, however much setup precedes it, is a feature test, and so is a
  refusal, whatever it counts. When the assertion would still be interesting had
  the earlier steps been arranged another way, they were setup.
- The two layers MUST NOT share one arrange object. Why: if the story's object
  exposes the feature suite's shortcuts, the one thing a story may never do
  becomes the handiest method on it.

## Naming and layout

When you are about to name or place a test:

- A PHPUnit test method MUST be camelCase, such as `testReturnsNullWhenNoMatch`.
  A Pest test name MUST be snake_case.
- Test folders MUST mirror the source folders: `Services/ExampleService.php` →
  `tests/Feature/Services/ExampleServiceTest.php`.
- A test MUST use named routes, not hardcoded URLs.

## Mocking

When you are about to mock:

- `shouldReceive()` MUST NOT be used. Why: without `times()`, a missed call
  passes silently.
- A class that needs mocking MUST NOT be `final`.

## Rules about the shape of the code go in an arch test

When you are about to enforce the shape of the code, or write a browser test:

- A shape rule a tool can enforce MUST go in `tests/Arch`; see `index.md` › A
  rule must be able to fail. It cannot see templates: a template is not an
  autoloaded class, so a helper call inside one passes every arch test.
- A browser test MUST only cover what needs a real browser, such as a real
  client-side runtime, a real DOM patch or a real teardown. Everything else is
  cheaper as a feature test.
- When the suite mixes runners, the one that executes all of them MUST be the one
  run. Why: a runner that silently skips a suite makes a green run prove nothing.
