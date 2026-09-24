# Event Sourcing Guidelines

Read this only in a project that stores events. Everything here is about what the
stream owes a reader ten years from now.

## Events

- An event is a fact that happened, in the past tense. Never a request, an
  intention or a command — nothing named `Should…`, `Request…` or `Do…`
- Store every event under a short alias, never its class name. A class name in the
  store means the stream breaks when a class is renamed or moved
- Every event is owned by exactly one aggregate root, and only that root records it
- An event never carries the id of the stream it is on — that is the stream's
  identity, already recorded, and a copy can disagree with it
- An identity on an event is a typed id, never a bare uuid type. The payload is
  the one place where a wrong id cannot be caught later
- Record what was actually charged, moved or issued — the resolved figure, not the
  inputs it was derived from. A later replay must not recompute it
- One command records its own transaction. Consequences that follow are their own
  events, recorded by whatever owns them
- Adding a field to an existing event means an upcaster stating what existing
  events used. A key absent from an old payload and filled from today's default
  silently changes what that stream folds to

## Aggregates

- Commands throw; they never record and then apologise. Validate, then record
- Validation goes in named guard methods, one rule per method, named after the
  rule it enforces
- A guard for a state no caller can reach is dead code — `architecture.md`
  § Absence must not be a side-channel
- State is a fold over the stream, so anything that varies must be pinned on the
  stream at creation — the ruleset, the mode, the settings — and never inferred at
  read time from current configuration
- A setting is a value the existing code already has a slot for; a ruleset is
  behaviour that needs new code. Settings are recorded, resolved, on every stream;
  rulesets are code-defined and named on the stream
- A setting is a constant that stopped being one: fold it when the creation event
  is applied, never read it from a class constant at the point of use, or a replay
  uses whatever the constant says today
- Split a large aggregate into partials by concern, and keep the split enforced —
  a partial may not reach into another partial's state
- Refuse snapshots until a stream is long enough to need one. A snapshot is a
  second representation of the state, and it goes stale in ways the fold cannot

## Read models

- Read models are disposable: anything in them must be rebuildable from the stream
  alone. Never write to a projection from anywhere but its projector
- A projection column with a second writer is a fact with two sources —
  `laravel.md` § Migrations
- A row's existence is a claim. If a zero row and a missing row mean the same
  thing, only one of them may be written
