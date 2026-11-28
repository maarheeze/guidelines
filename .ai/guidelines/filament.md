# Filament

## Relation managers

When you are about to write a relation manager: its `$relationship` MUST be
`static`. Why: Filament never reads it otherwise.

## Custom actions

When you are about to create a custom action class:

- It MUST override `make()`, not `setUp()`, so it configures through the fluent
  interface.
- It MUST be named after what it does, not the models it relates to:
  `AttachWithDescriptionAction`, not `EventVolunteerAttachAction`.

## Searchable columns

When you are about to mark a table column `->searchable()`: the column MUST get a
database index, inline on its definition in the migration with `->index()`.

## Schemas

When you are about to write a form, table or infolist definition:

- It MUST be its own schema class under `Schemas/`, never inline on the
  resource.
- Its entry point MUST be `configure(Schema $schema): Schema`, and it MUST expose
  its individual components through `getComponents(): array<Component>`.

## Class names

When you are about to type a Filament class name: you MUST first verify its
namespace against the installed vendor source. Why: Filament moves classes
between namespaces across versions, and a remembered path resolves to nothing.
