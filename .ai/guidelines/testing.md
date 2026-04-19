# Testing Guidelines

## Test Naming

- PHPUnit test method names use camelCase (e.g. `testReturnNullWhenNoMatch`)
- Pest test method names use snake_case

## Setup & Fixtures

- Do not use the `setUp()` method as a constructor to setup (mock-)classes — use explicit test methods or factory patterns instead
- If using pest: test closure must not be static

## Routing

- Use named routes if the framework supports it (instead of hardcoded URLs).

## Test data

- use fake data if the value is not of any value for the test itself
- add a custom faker generator for often-used variables (a good example are valueObjects), so you can use fake()->myValueObject() 

## Mocking

- Do not use the `shouldReceive()` method on mocked objects — it has the side-effect that without `times()` it can be missed silently
- Do not mark a class `final` if it needs to be mocked in tests