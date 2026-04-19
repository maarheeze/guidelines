# Laravel Guidelines

## Database & Queries

- Never use `DB::table()`, the `DB` facade, or any raw SQL (`selectRaw`, `whereRaw`, `orderByRaw`, etc.) — use Eloquent model queries instead
- Avoid Laravel helper functions (e.g. `view()`, `app()`, `route()`, `now()`, `abort()`) — use dependency injection wherever possible; only fall back to helpers in genuinely static or framework-constrained contexts (e.g. static Filament resource methods, Livewire component methods) where constructor injection is not available
- Never use `HasManyThrough` — move the query into the class that needs it instead

## Migrations

- When creating a migration, do not create the down migrations
- In migrations, separate these groups with a blank line in this order: id, foreign keys, fields, timestamps (incl. softDeletes if any), indexes
- Single-column indexes go inline on the column definition (e.g. `->index()`, `->unique()`); the indexes group is only for multi-column indexes

## Models

- Always create a factory alongside a new model
- Order methods as: Laravel override methods first (e.g. `casts()`, `booted()`), then relations alphabetically, then custom methods alphabetically
- Models must have a class-level docblock with `@property` for every column not already covered by a used trait
    - Derive types from `casts()`; uncasted columns default to `string`
    - Nullable columns get `?type`
    - Follow with a blank line and `@property-read` for every relation
    - Both groups are listed alphabetically
- Every model must have a corresponding custom collection class in `app/Collections/` (e.g. `TaskCollection extends Collection`), with `newCollection()` overridden on the model
- Use the typed collection everywhere the model appears as a collection (relation docblocks, return types, etc.)

## Factories

- In factories, each field uses an independent fake value — do not derive one field's value from another
- In factories, nullable foreign keys are optional: randomly either a related factory or null (e.g. `fake()->optional()->passthrough(RelatedModel::factory())`)
- In factories, use non-overlapping ranges to keep related date fields logically valid (e.g. starts_at between now and +1 month, ends_at between +1 and +2 months)

## Seeders

- In seeders, prefer explicit `foreach` loops with ID overrides over nested `has()` factory chains

## Blade

- Do not add comments in Blade views (no `{{-- ... --}}`)

## Translations

- Translation keys should reflect the concept, not per se the database column — use `organisation` not `organisation_id`
- For relation field labels, reuse the related model's `model_label` translation instead of duplicating the concept (e.g. `Trans::string('organisation.model_label')` instead of adding `organisation` to the current model's lang file)
- If the app uses translations, use them everywhere — including Blade views; never use hardcoded strings

## Forms & Requests

- Use FormRequests for validation — never call `$request->validate()` inside a controller

## Redirects

- Never use redirect()->back(): always explicitly route to the correct location