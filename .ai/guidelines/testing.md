# Testing Guidelines

## Test Naming

- PHPUnit test method names use camelCase (e.g. `testReturnNullWhenNoMatch`)
- Pest test method names use snake_case

## Setup & Fixtures

- Do not use the `setUp()` method as a constructor to setup (mock-)classes — use explicit test methods or factory patterns instead
- If using pest: test closure must not be static

## Namespaces

- Test folders should mimick the folder structure of the application: `app/Service/ExampleService.php` should have a `tests/Feature/Services/ExampleServiceTest.php` file
- Use a `Feature`-folder for featuretests and `Unit` for unit tests
- A unit test only test the class under test: no I/O, database, framework or whatsoever. Use mocks (Mockery) if more complex dependencies are needed
- Prefer Feature-tests over Unit-tests: Unit tests are for use-cases that are "harder to cover" using feature-tests (like exception handling etc) 

## Routing

- Use named routes if the framework supports it (instead of hardcoded URLs).

## Test data

- use fake data if the value is not of any value for the test itself
- add a custom faker generator for often-used variables (a good example are valueObjects), so you can use fake()->myValueObject() 

## Mocking

- Do not use the `shouldReceive()` method on mocked objects — it has the side-effect that without `times()` it can be missed silently
- Do not mark a class `final` if it needs to be mocked in tests

## Writing tests

- Never make try/catch-blocks in tests, use assertions and/or $this->expectException();