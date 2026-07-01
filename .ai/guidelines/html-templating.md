# HTML & template formatting

These rules apply to any markup that mixes HTML with control-flow directives — Blade, Twig, JSX, Vue, ERB, etc.

## Indentation
- 4 spaces, one step per nesting level. Both HTML elements and template control-flow directives (e.g. @if, @foreach, {% if %}, JSX conditionals) count as a nesting level.
- A directive body is indented 4 from its opening directive, the same way a PHP if block body is indented from the if.

## Element layout
- When a tag wraps a template expression, multiple lines of content, or another nested element, the opening tag, body, and closing tag each get their own line. The body indents 4 from the opening tag.
- Tags whose entire content fits cleanly on one line stay on one line (<th>Datum</th>, <a href="..."><button>...</button></a>).
- Long attribute lists wrap with subsequent attributes aligned under the first attribute on the opening tag's line.
- When an opening tag's attributes don't fit on one line, drop every attribute to its own line indented 4 from the opening tag — don't leave the first attribute on the tag's line. The closing `>` or `/>` stays at the end of the last attribute.

## Control-flow directives
- Each directive (@if, @else, @endif, @foreach, @endforeach, or the equivalent in the template engine in use) sits on its own line.
- Do not inline directives mid-element to avoid whitespace — write the structured form even if it adds a line or two.
- Prefer the engine's attribute directives over building attributes by hand with `@if` or ternaries. In Blade:
  - Boolean attributes: `@checked($expr)`, `@selected($expr)`, `@disabled($expr)`, `@readonly($expr)`, `@required($expr)` instead of `@if ($expr) checked @endif` etc.
  - Class and style strings: `@class([...])` and `@style([...])` with a conditional array instead of stuffing `@if`/ternaries into a `class=""` or `style=""` value.
  - Use `@forelse` / `@empty` for "list with empty fallback" instead of an outer `@if (count(...) === 0)` wrapping a `@foreach`. It removes one nesting level and makes the empty branch sit visually next to the loop it belongs to.

## Whitespace
- No decorative blank line right after a wrapping container's opening tag, or right before its closing tag.
- One blank line between sibling block-level children of a container is fine when each child is itself a multi-line block (e.g. field <div>s inside a <form>, card <div>s inside a grid, <section>s inside a layout). No blank lines around single-line / inline content, inside table rows, list items, or <p>/<span> bodies.

## Expressions
- Template output expressions get spaces inside their delimiters: {{ $foo }}, {{ expression }}, {% expression %} — not {{$foo}}.

## Logic in templates
- Templates do not import or resolve application classes. No `@use(App\Services\...)`, no `@php use App\...; @endphp`, no `app(SomeService::class)`, no `new SomeService(...)`. If the view needs computed data, the controller / Livewire component / view model prepares it and passes it in.
- Framework facades and global helpers are fine: `Auth::user()`, `Route::is(...)`, `route()`, `asset()`, `config()`, `__()`, and project-level presentation facades like `DateFormat::date(...)`. They're the framework's public API for the view layer, not service-layer wiring.
- No `@php ... @endphp` blocks in templates. Templates do not run statements — no variable assignments, no transformations, no inline computation. If the view needs a derived value, the controller / Livewire component / view model / parent component computes it and passes it in (as a prop, view data, or computed property).
- Templates don't read transient application state. No `session(...)`, no `request(...)`, no `Model::find(...)`. Flash messages, form input, current request data, query results — all of it is passed in as view data by the controller / Livewire component / view model.
