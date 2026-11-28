# Laravel

## Database and queries

When you are about to write a query:

- It MUST be an Eloquent model query. `DB::table()`, the `DB` facade and raw
  SQL, such as `selectRaw`, `whereRaw` and `orderByRaw`, MUST NOT be used.
- A facade MUST NOT be used any more than a helper; see `architecture.md` ›
  Dependencies. A template MAY only keep the calls that build a URL; see
  `html-templating.md` › A template draws what it was given.
- `HasManyThrough` MUST NOT be used; the query MUST move into the class that
  needs it.
- A value object MUST be passed straight to query methods, such as `where` and
  `whereKey`, and to test helpers, such as `assertDatabaseHas`, without
  `->toString()`. Why: the binding stringifies it through `__toString()`.
- A value object MAY only be stringified when the target API is typed `string`.
- A model MUST NOT be passed to `where()`; `whereKey()` or `$model->getKey()`
  MUST be used. Why: it binds the model's JSON and silently matches nothing.
- A lookup by key MUST be `whereKey($valueObject)->firstOrFail()`, not
  `findOrFail($valueObject)`. Why: `findOrFail` also accepts arrays, so it
  returns `Model|Collection` and fails PHPStan at max.

## Migrations

When you are about to write a migration:

- It MUST NOT have a down migration.
- Its groups MUST be separated by a blank line, in this order: id, foreign keys,
  fields, timestamps (including softDeletes), indexes.
- A single-column index MUST go inline on the column definition, with
  `->index()` or `->unique()`. The indexes group MUST only hold multi-column
  indexes.
- `->after()` MUST NOT be used to position a column.
- A schema `->default()` MUST NOT be added on a column something else also
  writes. Why: it is a second writer for that value; pick one.

When you are about to edit a migration that is already committed: you MUST NOT.
The one exception is a project with no deployed database and no data to protect,
and it is the project that says so, not you.

## Data in migrations

When you are about to change data in a migration:

- It MUST only convert existing data into the shape the code of this release
  reads, such as a renamed key, a reshaped value or a moved column. Why: the
  migration runs at its place in the schema history, while the old shape still
  exists; a command runs against whatever schema is there that day.
- It MUST only touch rows still in the old shape, so a second run changes
  nothing.
- It MUST NOT use application code, such as models, casts, enums, services or
  config: only the schema builder, the query builder and static values. This
  overrides Database and queries for migrations. Why: the application changes
  later; the migration must not.
- It MUST NOT insert data, such as roles, settings or defaults, or fix up data
  for reasons of its own. That belongs in a seeder or a command, which runs when
  someone decides it should.

## Models

When you are about to create a model or a database structure: you MUST ask for
the required fields before generating any code.

When you are about to create or change a model:

- A new model MUST get a factory.
- Its methods MUST be ordered: Laravel override methods first, such as `casts()`
  and `booted()`, then relations alphabetically, then custom methods
  alphabetically. This overrides `php.md` › Code organization for models.
- It MUST have a class-level docblock with a `@property` for every column not
  already covered by a used trait: typed from `casts()`, `string` when not cast,
  and `?type` when nullable. A blank line and a `@property-read` for every
  relation MUST follow. Both groups MUST be alphabetical.
- It MUST have its own collection class in a `Collections` folder next to the
  `Models` folder, such as `TaskCollection extends Collection`, returned by an
  overridden `newCollection()`. That typed collection MUST be used everywhere the
  model appears as a collection.
- It MUST stay thin: casts, relations, scopes and simple accessors only.
  Business rules, guards and invariants MUST go into a service or action.
- A value object MUST reach the read models through a cast, so a column's
  concept is typed at the boundary and never reassembled by callers.
- A concept spanning two columns MUST have one method that assembles it and one
  that writes it back, and those two MUST be the only place the pair is taken
  apart.

## Factories

When you are about to write a factory:

- Each field MUST use an independent fake value, never one derived from another
  field.
- A nullable foreign key MUST be optional, randomly a related factory or null,
  such as `fake()->optional()->passthrough(RelatedModel::factory())`.
- Related date fields MUST use non-overlapping ranges to stay logically valid,
  such as starts_at between now and +1 month and ends_at between +1 and +2
  months.

## Seeders

When you are about to write a seeder: it SHOULD use explicit `foreach` loops with
ID overrides instead of nested `has()` factory chains.

## Requests

When you are about to validate a request: it MUST be validated in a FormRequest,
never with `$request->validate()` inside a controller.

## Redirects

When you are about to redirect: it MUST route explicitly to the correct location,
never with `redirect()->back()`.
