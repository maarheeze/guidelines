# HTML and templates

For any markup that mixes HTML with control-flow directives, such as Blade, Twig,
JSX, Vue or ERB.

## Indentation

When you are about to indent markup:

- Indentation MUST be 4 spaces, one step per nesting level. HTML elements and
  control-flow directives, such as `@if`, `@foreach`, `{% if %}` and JSX
  conditionals, both count as a level.
- A directive body MUST be indented 4 from its opening directive, the same way a
  PHP if body is indented from its if.

## Element layout

When you are about to lay out an element:

- When a tag wraps a template expression, multiple lines of content or another
  nested element, the opening tag, the body and the closing tag MUST each be on
  their own line, with the body indented 4 from the opening tag.
- A tag whose whole content fits cleanly on one line MUST stay on one line, such
  as `<th>Datum</th>` or `<a href="..."><button>...</button></a>`.
- When an opening tag's attributes do not fit on one line, every attribute MUST
  go on its own line, indented 4 from the opening tag, with none left on the
  tag's line. The closing `>` or `/>` MUST stay at the end of the last attribute.

## Control-flow directives

When you are about to write a directive:

- Each directive, such as `@if`, `@else`, `@endif`, `@foreach` and
  `@endforeach`, or its equivalent in the engine in use, MUST be on its own line.
- A directive MUST NOT be inlined mid-element to avoid whitespace. The structured
  form MUST be written, even when it adds a line or two.
- The engine's attribute directives SHOULD be used instead of building
  attributes by hand with `@if` or ternaries. In Blade:
  - boolean attributes: `@checked($expr)`, `@selected($expr)`,
    `@disabled($expr)`, `@readonly($expr)`, `@required($expr)`
  - class and style strings: `@class([...])` and `@style([...])` with a
    conditional array
  - a list with an empty fallback: `@forelse` / `@empty`, instead of an outer
    `@if (count(...) === 0)` wrapping a `@foreach`

## Whitespace

When you are about to put a blank line in markup:

- A wrapping container MUST NOT have a blank line right after its opening tag or
  right before its closing tag.
- A blank line MAY separate sibling block-level children when each child is
  itself a multi-line block. There MUST NOT be blank lines around single-line or
  inline content, or inside table rows, list items, or `<p>` and `<span>`
  bodies.

## Expressions

When you are about to write an output expression: it MUST have spaces inside its
delimiters, such as `{{ $foo }}` and `{% expression %}`, not `{{$foo}}`.

## A template draws what it was given

When you are about to make a template use something it was not handed:

- A template MUST NOT import or resolve application classes: no
  `@use(App\...)`, no `@php use App\...; @endphp`, no `app(SomeService::class)`,
  no `new Service(...)`.
- It MUST NOT have `@php ... @endphp` blocks. A template does not run
  statements: no assignments, no transformations, no inline computation.
- It MUST NOT make a global call that fetches application state, such as the
  clock, config, the session, the request, the authenticated user, old input or a
  model lookup. This refuses the concept, not a list of names: the next helper
  the framework ships is refused on the same grounds, and so is the facade
  spelling of the same call.
- It MAY call what only turns arguments it already holds into a URL: `route`,
  `asset` and `url`. They read no application state.
- It MAY branch on the thing in its hand, such as a long name, an empty list or
  this row being the selected one. It MUST NOT go to a second thing to decide
  with, such as a lookup into another collection to answer "may this one be
  picked?"; that is the component's job. The `if` is not the problem; the lookup
  feeding it is.
- When the screen must not offer someone, the template MUST be handed a list
  without them, not a list plus a flag. A view model that carries the same people
  plus an `isAvailable` flag MUST NOT be built. Why: that is a set difference
  dressed as a type.

## Markup that appears in two templates is a component

When you are about to paste markup into a second template:

- You MUST name the concept and extract it to a component.
- Differing wrappers are no reason to copy: the wrapper MUST stay in each
  template, and the shared inside MUST become the component.

Why: the one-home rule does not stop at the language boundary. Extracting the PHP
side correctly while copying the markup is the same concept living in two homes.

## Translations

When you are about to write text, a translation key or a label:

- When the app uses translations, every string MUST come from them, including in
  templates. A hardcoded string MUST NOT be used.
- A translation key MUST reflect the concept, not the database column:
  `organisation`, not `organisation_id`.
- A relation's label MUST reuse the related model's own label key, not duplicate
  the concept.
- An enum case name MUST NOT be used as a display string, and MUST NOT change to
  suit the UI. Why: it is a language-neutral identifier, and it is what the store
  persists.
- An enum's labels MUST come from translation files keyed on the case name. A
  `label()` method returning a hardcoded English string MUST NOT be added.
- A symbol, such as `+`, `−`, a glyph or a digit, and a proper noun, such as a
  brand or product name, MUST NOT be translated. Why: a translator would have
  nothing to do.
