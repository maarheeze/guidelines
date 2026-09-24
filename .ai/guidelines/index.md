# Guidelines index

Open the file whose globs match the path you are about to edit, before editing it.

| Globs | File |
|---|---|
| `**/*.php` | `architecture.md`, `php.md` |
| `app/**`, `database/**`, `routes/**`, `config/**` | `laravel.md` |
| `app/Aggregates/**`, `app/Projectors/**`, `**/Events/**` | `event-sourcing.md` |
| `app/Filament/**` | `filament.md` |
| `app/Livewire/**`, `resources/js/**` | `livewire.md` |
| `resources/views/**` | `html-templating.md`, `livewire.md` |
| `tests/**` | `testing.md` |

## A rule must be able to fail

Before adding anything here, answer one question: how does this fail without a
human noticing?

- It can fail on its own — a sniff, a PHPStan rule, an arch test, a runtime guard.
  Then build that, and write at most a pointer here. A rule that fails
  mechanically does not need to be read to be obeyed.
- It cannot. Then it is judgement, it belongs here, and it will be broken
  sometimes — so keep it short enough to be read again.

Every addition lowers the odds that any single rule is read. A rule that carries
teeth elsewhere shrinks to one line naming where the failure comes from.

## Name the moment, not the virtue

The reader is an agent, mid-task. A bullet that states a desired end state never
fires, because nothing in the moment announces itself as over-engineering or as a
large refactor. A bullet that names the observable trigger does: the sentence you
are about to write, the tool you are about to call, the word in the user's
message.

So each line says when it applies, and a line that cannot fail observably is
deleted rather than kept as encouragement — it dilutes the ones that can.
