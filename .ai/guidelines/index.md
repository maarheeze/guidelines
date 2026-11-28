# Guidelines index

When you are about to edit a file: you MUST first open every file whose globs
match its path.

| Globs | File |
|---|---|
| `**/*.php` | `architecture.md`, `php.md`, `laravel.md` |
| `**/Aggregates/**`, `**/Projectors/**`, `**/Events/**` | `event-sourcing.md` |
| `**/Filament/**` | `filament.md` |
| `**/Livewire/**`, `**/js/**` | `livewire.md` |
| `**/views/**` | `html-templating.md`, `livewire.md` |
| `tests/**` | `testing.md` |

## The working agreement

- MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are used as defined in RFC 2119. A
  SHOULD MAY only be deviated from with a reason, which is stated to the user.
- When a line here contradicts a Laravel Boost guideline or any other framework
  or package guideline, the line here MUST be followed. For example, Boost's
  TitleCase enum cases lose to `php.md`'s capitals with underscores.

## A rule must be able to fail

When you are about to add a rule here: first answer how it fails without a human
noticing.

- When it can fail on its own, such as through a sniff, a PHPStan rule, an arch
  test or a runtime guard, that check MUST be built instead, with at most a
  pointer to it here. Why: a rule that fails mechanically does not need to be
  read to be obeyed.
- When it cannot, it is judgement and belongs here. It MUST be kept short enough
  to be read again, because it will be broken sometimes.
- A rule enforced elsewhere MUST shrink to one line naming where the failure
  comes from.

Why: every addition lowers the odds that any single rule is read.

## Writing a rule

When you are about to write a rule:

- Its section MUST open with the moment it applies in: the sentence you are about
  to write, the tool you are about to call, the word in the user's message. It
  MUST NOT state a desired end state. Why: the reader is an agent mid-task, and
  nothing in the moment announces itself as over-engineering or as a large
  refactor.
- The rule MUST be one sentence that says MUST, MUST NOT, SHOULD, SHOULD NOT or
  MAY.
- Its reason SHOULD be one "Why:" line, after the rule or at the end of its
  section.
- An example MAY be given, marked as one ("such as", "for example"). The rule
  MUST hold without it.
- A line that cannot fail observably MUST be deleted rather than kept as
  encouragement. Why: it dilutes the ones that can.
