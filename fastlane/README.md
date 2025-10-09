fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the project

### ios test

```sh
[bundle exec] fastlane ios test
```

Run all tests (Unit + UI)

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

Run unit tests only

### ios ui_tests

```sh
[bundle exec] fastlane ios ui_tests
```

Run UI tests only

### ios build_for_testing

```sh
[bundle exec] fastlane ios build_for_testing
```

Build for testing (used in CI)

### ios test_without_building

```sh
[bundle exec] fastlane ios test_without_building
```

Run tests without building (used in CI)

### ios coverage

```sh
[bundle exec] fastlane ios coverage
```

Generate code coverage report

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Lint Swift code

### ios ci

```sh
[bundle exec] fastlane ios ci
```

Run full CI pipeline

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean build artifacts

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
