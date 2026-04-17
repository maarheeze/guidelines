# Architecture Guidelines

## Design Principles

- Prefer explicit over clever — readable code over compact code
- Keep classes focused on a single responsibility
- Prefer composition over inheritance

## Method Overrides

- Always match the parent method signature exactly when overriding, including nullable types and default values

## Code Formatting

- Constructor parameters are always each on their own line, with a trailing comma
- Chain length determines formatting:
    - 1–2 chained calls stay on one line
    - 3 or more chained calls each go on their own line

Example:
```php
// OK
$result = $query->where('active', true)->first();

// OK
$result = $query
    ->where('active', true)
    ->orderBy('created_at')
    ->first();
```

## Properties

- Make properties readonly if possible
- If all constructor properties are readonly (or the class is `readonly`), declare the class as `readonly` and omit `readonly` from individual properties