# Filament Guidelines

## You are writing a relation manager

- `$relationship` is `static`, or Filament never reads it

## You are creating a custom action class

- Override `make()`, not `setUp()`, so it configures through the fluent interface
- Name it after what it does, not the models it relates to —
  `AttachWithDescriptionAction`, not `EventVolunteerAttachAction`

## You are marking a table column `->searchable()`

- That column needs a database index. Add it inline on the column definition with
  `->index()` in the migration

## You are writing a form, table or infolist definition

- It goes in its own schema class under `Schemas/`, never inline on the resource
- `configure(Schema $schema): Schema` is the entry point
- `getComponents(): array<Component>` exposes the individual components

## You are about to type a Filament class name

- Verify the namespace against the installed vendor source first. Filament moves
  classes between namespaces across versions, and a remembered path resolves to
  nothing
