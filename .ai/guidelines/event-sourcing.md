# Event sourcing

Only for a project that stores events. Everything here is about what the stream
owes a reader ten years from now.

## Events

When you are about to write or change an event:

- It MUST be a fact that happened, in the past tense. It MUST NOT be a request,
  an intention or a command, such as anything named `Should…`, `Request…` or
  `Do…`.
- It MUST be stored under a short alias, never its class name. Why: a class name
  in the store breaks the stream when the class is renamed or moved.
- It MUST be owned by exactly one aggregate root, and only that root MUST record
  it.
- It MUST NOT carry the id of the stream it is on. Why: that is the stream's
  identity, already recorded, and a copy can disagree with it.
- An identity on it MUST be a typed id, never a bare uuid type. Why: the payload
  is the one place where a wrong id cannot be caught later.
- It MUST record what was actually charged, moved or issued: the resolved
  figure, not the inputs it was derived from. Why: a later replay must not
  recompute it.
- A command MUST record only its own transaction. Consequences that follow MUST
  be their own events, recorded by whatever owns them.
- A field added to an existing event MUST come with an upcaster that states what
  existing events used. Why: a key absent from an old payload and filled from
  today's default silently changes what that stream folds to.

## Aggregates

When you are about to write a command or change an aggregate:

- A command MUST validate, then record. It MUST throw, never record and then
  apologise.
- Validation MUST be in named guard methods, one rule per method, named after the
  rule it enforces. A guard for a state no caller can reach MUST NOT be written;
  see `architecture.md` › Absence must not be a side-channel.
- Anything that varies, such as the ruleset, the mode and the settings, MUST be
  pinned on the stream at creation, and never inferred at read time from current
  configuration. Why: state is a fold over the stream.
- A setting, a value the existing code already has a slot for, MUST be recorded,
  resolved, on every stream. A ruleset, behaviour that needs new code, MUST be
  defined in code and named on the stream.
- A setting MUST be folded when the creation event is applied, never read from a
  class constant at the point of use. Why: a setting is a constant that stopped
  being one, and a replay uses whatever the constant says today.
- A large aggregate MUST be split into partials by concern, and a partial MUST
  NOT reach into another partial's state.
- A snapshot MUST NOT be added until a stream is long enough to need one. Why: a
  snapshot is a second representation of the state, and it goes stale in ways
  the fold cannot.

## Read models

When you are about to write to a read model:

- Everything in it MUST be rebuildable from the stream alone. It MUST NOT be
  written to from anywhere but its projector.
- A projection column MUST NOT have a second writer; see `laravel.md` ›
  Migrations.
- When a zero row and a missing row mean the same thing, only one of them MUST
  ever be written. Why: a row's existence is a claim.
