# Guidelines

Development guidelines for AI agents and developers.

## Installation

```bash
composer require maarheeze/guidelines --dev
```

## With Laravel Boost

If using Laravel Boost, also install:

```bash
composer require maarheeze/boost-guidelines --dev
php artisan boost:install
php artisan boost:update --discover
```

## Two delivery paths

Guidelines reach an agent in one of two ways, and which one a file uses is decided by
where it lives.

**`.ai/guidelines/always/` is inlined.** Everything in this directory is placed in the
agent's always-on context, before it has read a line of the task. It is for rules that
must hold whether or not the agent opened anything — how to work with the user, what it
may not do on your machine. Keep it ruthlessly small — everything here is paid for on
every task, whether or not it turns out to be relevant.

**Everything else is pulled through the index.** `.ai/guidelines/index.md` maps file
globs to guideline files. An agent opens the index, then opens only the files whose globs
match the path it is about to edit. A file that matches nothing in your project costs
that project nothing.

## Writing a guideline file

Add the file to the table in `index.md`, with the globs it applies to:

```markdown
| `**/*.php` | `php.md` |
```

The index is the only route to a file, so one that is missing from the table is never
delivered. The file itself says nothing about its own scope — the table is the single
place globs are written down.

## Override in Your Project

Add `.ai/guidelines/` files to override any guideline.
