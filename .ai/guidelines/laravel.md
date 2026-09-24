# Laravel Guidelines

## Database & Queries

- Never use `DB::table()`, the `DB` facade, or any raw SQL (`selectRaw`,
  `whereRaw`, `orderByRaw`, etc.) — use Eloquent model queries instead
- The rule on hidden dependencies is in `architecture.md` § Dependencies; in
  Laravel it also bans every facade, not only the helper
- Templates are the one place a global call survives, and only for URL building —
  `html-templating.md` says which
- Never use `HasManyThrough` — move the query into the class that needs it
- Pass value objects straight to query methods (`where`, `whereKey`) and test
  helpers (`assertDatabaseHas`). Do not call `->toString()` — the binding
  stringifies the object via `__toString()`
- Never pass a model to `where()` — it binds the model's JSON and silently matches
  nothing. Use `whereKey()` or `$model->getKey()`
- Only stringify a value object when the target API is typed `string`
- Use `whereKey($valueObject)->firstOrFail()`, not `findOrFail($valueObject)` —
  `findOrFail` also accepts arrays, so it returns `Model|Collection` and fails
  PHPStan at max

## Migrations

- When creating a migration, do not create the down migrations
- In migrations, separate these groups with a blank line in this order: id,
  foreign keys, fields, timestamps (incl. softDeletes if any), indexes
- Single-column indexes go inline on the column definition (`->index()`,
  `->unique()`); the indexes group is only for multi-column indexes
- Never use `->after()` to give a column a certain position
- Never edit a committed migration. The one exception is a project with no
  deployed database and no data to protect, and it is the project that says so —
  not you
- A schema `->default()` on a column something else also writes is a second writer
  for that value. Pick one

## Models

- When creating models or database structures, always ask for the required fields
  before generating any code
- Always create a factory alongside a new model
- Order methods as: Laravel override methods first (`casts()`, `booted()`), then
  relations alphabetically, then custom methods alphabetically — this outranks
  `php.md` § Code Organization for models
- Models must have a class-level docblock with `@property` for every column not
  already covered by a used trait
    - Derive types from `casts()`; uncasted columns default to `string`
    - Nullable columns get `?type`
    - Follow with a blank line and `@property-read` for every relation
    - Both groups are listed alphabetically
- Every model must have a corresponding custom collection class in
  `app/Collections/` (e.g. `TaskCollection extends Collection`), with
  `newCollection()` overridden on the model
- Use the typed collection everywhere the model appears as a collection
- Keep models thin: casts, relations, scopes and simple accessors only. Business
  rules, guards and invariants belong in a service or action
- Value objects reach the read models through casts, so a column's concept is
  typed at the boundary and never reassembled by callers
- A concept spanning two columns gets one method that assembles it and one that
  writes it back — and those two are the only place the pair is taken apart

## Factories

- In factories, each field uses an independent fake value — do not derive one
  field's value from another
- In factories, nullable foreign keys are optional: randomly either a related
  factory or null (e.g. `fake()->optional()->passthrough(RelatedModel::factory())`)
- In factories, use non-overlapping ranges to keep related date fields logically
  valid (e.g. starts_at between now and +1 month, ends_at between +1 and +2 months)

## Seeders

- In seeders, prefer explicit `foreach` loops with ID overrides over nested
  `has()` factory chains

## Forms & Requests

- Use FormRequests for validation — never call `$request->validate()` inside a
  controller

## Redirects

- Never use `redirect()->back()` — always route explicitly to the correct location
