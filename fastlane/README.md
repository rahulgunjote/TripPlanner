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

Run all tests

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

Run unit tests only

### ios build_for_testing

```sh
[bundle exec] fastlane ios build_for_testing
```

Build for testing (used in CI)

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

### ios launchable_record_build

```sh
[bundle exec] fastlane ios launchable_record_build
```

Record build for Launchable

### ios launchable_train

```sh
[bundle exec] fastlane ios launchable_train
```

Run full test suite and upload to Launchable (for training ML models)

### ios launchable_subset_test

```sh
[bundle exec] fastlane ios launchable_subset_test
```

Run tests with Launchable intelligent subset (for PRs)

### ios launchable_test

```sh
[bundle exec] fastlane ios launchable_test
```

Run tests with Launchable (with fallback)

### ios launchable_verify

```sh
[bundle exec] fastlane ios launchable_verify
```

Verify Launchable setup

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean build artifacts

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
