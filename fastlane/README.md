# Fastlane Documentation

## TripPlanner Fastlane Setup

This documentation provides an overview of the available Fastlane lanes for the TripPlanner iOS application.

---

## Installation

### Prerequisites
- Ruby 3.3.5
- Xcode 16.0+
- Bundler

### Setup
```bash
# Install bundler if not already installed
gem install bundler

# Install dependencies
bundle install
```

---

## Available Lanes

### 🔨 Build Lanes

#### `build`
Builds the project in Debug configuration for the iPhone 17 simulator.

```bash
bundle exec fastlane build
```

**Usage:**
- Clean build of the project
- Used for verifying build configuration
- Outputs to DerivedData

---

#### `build_for_testing`
Builds the project specifically for running tests (optimized for CI).

```bash
bundle exec fastlane build_for_testing
```

**Usage:**
- Prepares build artifacts for testing
- Used in CI to separate build and test steps
- Faster test execution when combined with `test_without_building`

---

### 🧪 Test Lanes

#### `test`
Runs all tests (Unit + UI) with code coverage.

```bash
bundle exec fastlane test
```

**Output:**
- HTML test report: `fastlane/test_output/report.html`
- JUnit XML: `fastlane/test_output/report.junit`
- Code coverage data

---

#### `unit_tests`
Runs only unit tests from the `TripPlannerTests` target.

```bash
bundle exec fastlane unit_tests
```

**Features:**
- Faster execution than full test suite
- Focused on business logic testing
- Code coverage enabled

**Output:**
- `fastlane/test_output/unit_tests/`

---

#### `ui_tests`
Runs only UI tests from the `TripPlannerUITests` target.

```bash
bundle exec fastlane ui_tests
```

**Features:**
- Tests user interface and interactions
- Captures screenshots on failure
- Code coverage enabled

**Output:**
- `fastlane/test_output/ui_tests/`

---

#### `test_without_building`
Runs tests using pre-built artifacts (used in CI).

```bash
# Run all tests
bundle exec fastlane test_without_building

# Run specific target
bundle exec fastlane test_without_building target:TripPlannerTests
```

**Usage:**
- Requires prior run of `build_for_testing`
- Speeds up CI by separating build and test phases

---

### 📊 Coverage & Quality

#### `coverage`
Generates detailed code coverage report using xcov.

```bash
bundle exec fastlane coverage
```

**Requirements:**
- Install xcov: `gem install xcov`

**Output:**
- HTML coverage report: `fastlane/test_output/coverage/index.html`
- Minimum coverage threshold: 60%

---

#### `lint`
Runs SwiftLint to check code style and quality.

```bash
bundle exec fastlane lint
```

**Requirements:**
- Install SwiftLint: `brew install swiftlint`

**Output:**
- HTML lint report: `fastlane/test_output/swiftlint.html`

---

### 🚀 CI Lanes

#### `ci`
Runs the complete CI pipeline: build + unit tests + UI tests.

```bash
bundle exec fastlane ci
```

**Steps:**
1. Build project
2. Run unit tests
3. Run UI tests

**Usage:**
- Local CI simulation
- Pre-push verification

---

### 🧹 Utility Lanes

#### `clean`
Cleans all build artifacts and derived data.

```bash
bundle exec fastlane clean
```

**Usage:**
- Resolves build issues
- Frees up disk space
- Fresh start for builds

---

## CI/CD Integration

### GitHub Actions

The project includes two GitHub Actions workflows:

#### Main Branch Workflow (`.github/workflows/main.yml`)
**Triggers:** Push to `main` branch

**Steps:**
1. Setup environment (Xcode 16.0, Ruby 3.3.5)
2. Build project
3. Run unit tests
4. Run UI tests
5. Upload test results and coverage

---

#### Pull Request Workflow (`.github/workflows/pr.yml`)
**Triggers:** Pull requests to `main` or `develop` branches

**Jobs:**
1. **Build Check:** Verifies project builds successfully
2. **Unit Tests:** Runs unit tests in parallel
3. **UI Tests:** Runs UI tests (depends on unit tests)

**Features:**
- Parallel execution for faster feedback
- Automatic PR comments with test results
- Test artifacts uploaded for 30 days
- Screenshots uploaded on UI test failures

---

## Configuration Files

### `Gemfile`
Defines Ruby dependencies and version.

```ruby
ruby "3.3.5"
gem "fastlane", "~> 2.221"
```

### `Appfile`
Contains app-specific configuration (bundle ID, Apple ID).

### `.swiftlint.yml`
SwiftLint configuration with custom rules.

### `.xcovignore`
Excludes test files from coverage reports.

### `.ruby-version`
Specifies Ruby version for rbenv/rvm.

---

## Troubleshooting

### Common Issues

#### Simulator Not Found
```bash
# List available simulators
xcrun simctl list devices available

# Update SIMULATOR variable in Fastfile
SIMULATOR = "iPhone 17"  # Or your available simulator
```

#### Build Failures
```bash
# Clean derived data
bundle exec fastlane clean

# Reset simulator
xcrun simctl erase all
```

#### Test Timeouts
- Increase timeout in `Fastfile` scan options
- Check simulator performance
- Reduce test parallelization

#### Ruby Version Mismatch
```bash
# Install correct Ruby version
rbenv install 3.3.5
rbenv local 3.3.5

# Or with rvm
rvm install 3.3.5
rvm use 3.3.5
```

---

## Local Development Workflow

### Before Committing
```bash
# Run full CI pipeline locally
bundle exec fastlane ci

# Or run tests individually
bundle exec fastlane build
bundle exec fastlane unit_tests
bundle exec fastlane ui_tests
```

### Quick Test Cycle
```bash
# Build once
bundle exec fastlane build_for_testing

# Run tests multiple times without rebuilding
bundle exec fastlane test_without_building
```

---

## Continuous Integration Best Practices

1. **Keep builds fast:** Use `build_for_testing` to separate concerns
2. **Run unit tests first:** Faster feedback loop
3. **Parallelize when possible:** UI and unit tests can run separately
4. **Cache dependencies:** Bundle cache speeds up CI
5. **Upload artifacts:** Always save test results and logs
6. **Monitor coverage:** Track trends over time

---

## Support

For more information:
- [Fastlane Documentation](https://docs.fastlane.tools)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

---

**Last Updated:** October 2025
**Fastlane Version:** 2.221+
**Ruby Version:** 3.3.5

