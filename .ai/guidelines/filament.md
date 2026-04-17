# Filament Guidelines

## Relation Managers

- `$relationship` in relation managers must be `static`

## Actions

- When creating a custom action class, override `make()` instead of `setUp()` to configure it via the fluent interface
- Name custom action classes after what they do, not the models they relate to (e.g. `AttachWithDescriptionAction`, not `EventVolunteerAttachAction`)

## Tables

- Columns marked `->searchable()` in a Filament table must have a corresponding database index
- Add indexes inline on the column definition using `->index()`

## Schema Organization

- Extract form, table, and infolist definitions into separate schema classes under `Schemas/`
- Use `configure(Schema $schema): Schema` as the main entry point
- Use `getComponents(): array<Component>` for individual component access

## Namespaces

- Always verify class namespaces against the installed vendor source before using them