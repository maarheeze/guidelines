# HTML & template formatting

These rules apply to any markup that mixes HTML with control-flow directives —
Blade, Twig, JSX, Vue, ERB, etc.

## Indentation
- 4 spaces, one step per nesting level. Both HTML elements and template
  control-flow directives (e.g. @if, @foreach, {% if %}, JSX conditionals) count
  as a nesting level.
- A directive body is indented 4 from its opening directive, the same way a PHP
  if block body is indented from the if.

## Element layout
- When a tag wraps a template expression, multiple lines of content, or another
  nested element, the opening tag, body, and closing tag each get their own line.
  The body indents 4 from the opening tag.
- Tags whose entire content fits cleanly on one line stay on one line
  (<th>Datum</th>, <a href="..."><button>...</button></a>).
- Long attribute lists wrap with subsequent attributes aligned under the first
  attribute on the opening tag's line.
- When an opening tag's attributes don't fit on one line, drop every attribute to
  its own line indented 4 from the opening tag — don't leave the first attribute
  on the tag's line. The closing `>` or `/>` stays at the end of the last
  attribute.

## Control-flow directives
- Each directive (@if, @else, @endif, @foreach, @endforeach, or the equivalent in
  the template engine in use) sits on its own line.
- Do not inline directives mid-element to avoid whitespace — write the structured
  form even if it adds a line or two.
- Prefer the engine's attribute directives over building attributes by hand with
  `@if` or ternaries. In Blade:
  - Boolean attributes: `@checked($expr)`, `@selected($expr)`, `@disabled($expr)`,
    `@readonly($expr)`, `@required($expr)`
  - Class and style strings: `@class([...])` and `@style([...])` with a
    conditional array
  - Use `@forelse` / `@empty` for "list with empty fallback" instead of an outer
    `@if (count(...) === 0)` wrapping a `@foreach`

## Whitespace
- No decorative blank line right after a wrapping container's opening tag, or
  right before its closing tag.
- One blank line between sibling block-level children of a container is fine when
  each child is itself a multi-line block. No blank lines around single-line or
  inline content, inside table rows, list items, or <p>/<span> bodies.

## Expressions
- Template output expressions get spaces inside their delimiters: {{ $foo }},
  {{ expression }}, {% expression %} — not {{$foo}}.

## A template draws what it was given

- Templates do not import or resolve application classes. No `@use(App\...)`, no
  `@php use App\...; @endphp`, no `app(SomeService::class)`, no `new Service(...)`
- No `@php ... @endphp` blocks. Templates do not run statements — no assignments,
  no transformations, no inline computation
- A global call that *fetches* application state is the template reaching past the
  component for something nobody handed it: the clock, config, the session, the
  request, the authenticated user, old input, a model lookup. This is the concept
  being refused, not a list of six names — the next helper the framework ships is
  refused on the same grounds, and so is the facade spelling of the same call
- What survives is the calls that only turn arguments the template already holds
  into a URL — `route`, `asset`, `url`. They read no application state
- Branching on the thing in its hand is ordinary presentation: a long name, an
  empty list, this row is the selected one
- Going to a *second* thing to decide with is not. A lookup into another
  collection to answer "may this one be picked?" is the component's job. The `if`
  is not the problem; the lookup feeding it is
- Hand the template a different list, not a list plus a flag. If the screen must
  not offer someone, leave them out of the collection
- Do not build a view model that carries the same people plus an `isAvailable`
  flag — that is a set difference dressed as a type

## Markup that appears in two templates is a component

- Before pasting markup into a second template, name the concept and extract it
  to a component
- Differing wrappers are not a reason to copy: the wrapper stays in each
  template, the shared inside becomes the component
- The one-home rule does not stop at the language boundary. Extracting the PHP
  side correctly while copying the markup is the same concept living in two homes

## Translations

- If the app uses translations, use them everywhere, including templates. Never a
  hardcoded string
- Translation keys reflect the concept, not the database column — `organisation`,
  not `organisation_id`
- For a relation's label, reuse the related model's own label key rather than
  duplicating the concept
- An enum case name is a language-neutral identifier and what the store persists.
  It is never a display string, and it never changes to suit the UI
- Labels come from translation files keyed on the case name. Do not add a
  `label()` method returning a hardcoded English string
- A symbol is not a label. `+`, `−`, a glyph, a digit are identical in every
  language, and a translation file for them is a lookup that can never vary. The
  test is whether a translator would have anything to do
- Proper nouns — brand names, product names — are not translated either
