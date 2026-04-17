# Testing Guidelines

## Test Naming

- PHPUnit test method names use camelCase (e.g. `testReturnNullWhenNoMatch`)
- Pest test method names use snake_case

## Setup & Fixtures

- Do not use the `setUp()` method as a constructor to setup (mock-)classes — use explicit test methods or factory patterns instead

## Mocking

- Do not use the `shouldReceive()` method on mocked objects — it has the side-effect that without `times()` it can be missed silently
- Do not mark a class `final` if it needs to be mocked in tests