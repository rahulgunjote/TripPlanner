# CI/CD Setup Guide - TripPlanner

## 🚀 Overview

This project uses **Fastlane** for automation and **GitHub Actions** for continuous integration and deployment.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Setup](#local-setup)
3. [Fastlane Lanes](#fastlane-lanes)
4. [GitHub Actions Workflows](#github-actions-workflows)
5. [Configuration Files](#configuration-files)
6. [Usage Examples](#usage-examples)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Xcode:** 16.0 or later
- **macOS:** Sonoma or later
- **Ruby:** 3.3.5
- **Bundler:** Latest version
- **Homebrew:** For installing dependencies

### Optional Tools
- **SwiftLint:** Code linting (install: `brew install swiftlint`)
- **xcov:** Coverage reports (install: `gem install xcov`)
- **rbenv/rvm:** Ruby version management

---

## Local Setup

### 1. Install Ruby 3.3.5

#### Using rbenv (Recommended)
```bash
# Install rbenv if not already installed
brew install rbenv

# Install Ruby 3.3.5
rbenv install 3.3.5

# Set local Ruby version for this project
cd /path/to/TripPlanner
rbenv local 3.3.5

# Verify
ruby -v  # Should show ruby 3.3.5
```

#### Using rvm
```bash
# Install rvm if not already installed
\curl -sSL https://get.rvm.io | bash -s stable

# Install Ruby 3.3.5
rvm install 3.3.5
rvm use 3.3.5

# Verify
ruby -v  # Should show ruby 3.3.5
```

### 2. Install Dependencies

```bash
# Navigate to project directory
cd /path/to/TripPlanner

# Install bundler
gem install bundler

# Install project dependencies
bundle install
```

### 3. Verify Setup

```bash
# Check fastlane installation
bundle exec fastlane --version

# List available lanes
bundle exec fastlane lanes
```

---

## Fastlane Lanes

### Build Lanes

| Lane | Description | Command |
|------|-------------|---------|
| `build` | Clean build of the project | `bundle exec fastlane build` |
| `build_for_testing` | Build optimized for testing | `bundle exec fastlane build_for_testing` |

### Test Lanes

| Lane | Description | Command |
|------|-------------|---------|
| `test` | Run all tests (Unit + UI) | `bundle exec fastlane test` |
| `unit_tests` | Run only unit tests | `bundle exec fastlane unit_tests` |
| `ui_tests` | Run only UI tests | `bundle exec fastlane ui_tests` |

### Quality Lanes

| Lane | Description | Command |
|------|-------------|---------|
| `coverage` | Generate coverage report | `bundle exec fastlane coverage` |
| `lint` | Run SwiftLint | `bundle exec fastlane lint` |

### CI/Utility Lanes

| Lane | Description | Command |
|------|-------------|---------|
| `ci` | Full CI pipeline (build + all tests) | `bundle exec fastlane ci` |
| `clean` | Clean build artifacts | `bundle exec fastlane clean` |

---

## GitHub Actions Workflows

### 1. Main Branch Workflow

**File:** `.github/workflows/main.yml`

**Triggers:**
- Push to `main` branch

**Jobs:**
```
build-and-test:
  ├── Checkout code
  ├── Setup Xcode 16.0
  ├── Setup Ruby 3.3.5
  ├── Install dependencies
  ├── Build project
  ├── Run unit tests
  ├── Run UI tests
  ├── Upload test results
  └── Upload code coverage
```

**Features:**
- ✅ Full build and test pipeline
- ✅ Code coverage reporting
- ✅ Test result artifacts (30 days retention)
- ✅ Automatic commit comments

---

### 2. Pull Request Workflow

**File:** `.github/workflows/pr.yml`

**Triggers:**
- Pull requests to `main` or `develop` branches

**Jobs:**

#### Job 1: Build Check
```
build-check:
  ├── Checkout code
  ├── Setup environment
  ├── Build project
  └── Comment on PR
```

#### Job 2: Unit Tests
```
unit-tests:
  ├── Checkout code
  ├── Setup environment
  ├── Build for testing
  ├── Run unit tests
  ├── Upload test results
  └── Comment on PR
```

#### Job 3: UI Tests (runs after unit tests)
```
ui-tests:
  ├── Checkout code
  ├── Setup environment
  ├── Build for testing
  ├── Run UI tests
  ├── Upload test results
  ├── Upload screenshots (on failure)
  └── Comment on PR
```

**Features:**
- ✅ Parallel execution (build-check and unit-tests run simultaneously)
- ✅ Sequential UI tests (runs after unit tests pass)
- ✅ Automatic PR comments with results
- ✅ Screenshot capture on UI test failures
- ✅ Test artifacts (30 days retention)

---

## Configuration Files

### Project Files

| File | Purpose |
|------|---------|
| `Gemfile` | Ruby dependencies and version |
| `.ruby-version` | Ruby version specification |
| `fastlane/Fastfile` | Fastlane lane definitions |
| `fastlane/Appfile` | App-specific configuration |
| `.swiftlint.yml` | SwiftLint rules |
| `.xcovignore` | Coverage exclusions |
| `.gitignore` | Git ignored files |

### Workflow Files

| File | Purpose |
|------|---------|
| `.github/workflows/main.yml` | Main branch CI workflow |
| `.github/workflows/pr.yml` | Pull request CI workflow |

---

## Usage Examples

### Local Development

#### Quick Test
```bash
# Run only unit tests (fastest)
bundle exec fastlane unit_tests
```

#### Full Local CI
```bash
# Simulate CI pipeline
bundle exec fastlane ci
```

### Pre-Commit Checks

```bash
# Before committing
bundle exec fastlane build      # Ensure it builds
bundle exec fastlane unit_tests # Run unit tests
bundle exec fastlane lint       # Check code style (if SwiftLint installed)
```

### Pre-Push Validation

```bash
# Full validation before pushing
bundle exec fastlane ci
```

---

## CI/CD Workflow Visualization

### Main Branch Flow
```
Push to main
    ↓
GitHub Actions Triggered
    ↓
Setup Environment (Xcode 16.0, Ruby 3.3.5)
    ↓
Build Project
    ↓
Run Unit Tests → Upload Results
    ↓
Run UI Tests → Upload Results + Screenshots
    ↓
Upload Coverage → Codecov
    ↓
✅ Success! Commit comment added
```

### Pull Request Flow
```
Create/Update PR
    ↓
GitHub Actions Triggered
    ↓
Three Jobs in Parallel:
    ├── Build Check
    │   ├── Build
    │   └── Comment: ✅ Build succeeded
    │
    ├── Unit Tests
    │   ├── Build for testing
    │   ├── Run unit tests
    │   ├── Upload results
    │   └── Comment: ✅ Unit tests completed
    │
    └── UI Tests (waits for unit tests)
        ├── Build for testing
        ├── Run UI tests
        ├── Upload results + screenshots
        └── Comment: ✅ UI tests completed
```

---

## Troubleshooting

### Common Issues

#### 1. Ruby Version Mismatch
```bash
# Error: Ruby version doesn't match
# Solution:
rbenv install 3.3.5
rbenv local 3.3.5
bundle install
```

#### 2. Bundler Issues
```bash
# Error: Can't find bundler
# Solution:
gem install bundler
bundle install
```

#### 3. Simulator Not Found
```bash
# Error: Simulator "iPhone 17" not found
# Solution 1: List available simulators
xcrun simctl list devices available

# Solution 2: Update Fastfile with your simulator name
# Edit fastlane/Fastfile: SIMULATOR = "iPhone 15 Pro"
```

#### 4. Xcode Command Line Tools
```bash
# Error: xcodebuild not found
# Solution:
sudo xcode-select --install
sudo xcode-select -s /Applications/Xcode.app
```

#### 5. Build Failures
```bash
# Clear derived data
bundle exec fastlane clean
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset simulators
xcrun simctl erase all
```

#### 6. Test Timeouts
```bash
# Increase timeout in Fastfile scan options:
# Add to scan block:
#   xcargs: "-maximum-concurrent-test-simulator-destinations 1"
```

#### 7. GitHub Actions Failures

**Xcode Version Not Found:**
- Update `.github/workflows/*.yml` with available Xcode version
- Check [GitHub Actions runner images](https://github.com/actions/runner-images)

**Simulator Issues in CI:**
- Use generic simulator names (e.g., "iPhone 15 Pro" instead of "iPhone 17")
- Check available simulators in CI logs

**Permission Denied:**
- Ensure GitHub Actions has proper permissions
- Check repository settings → Actions → General → Workflow permissions

---

## Performance Optimization

### Local Development
```bash
# Run all tests
bundle exec fastlane test

# Or run specific test types
bundle exec fastlane unit_tests
bundle exec fastlane ui_tests
```

### CI Optimization
- ✅ Parallel jobs for faster feedback
- ✅ Bundler cache in GitHub Actions
- ✅ Separate build and test phases
- ✅ Unit tests before UI tests (fail fast)

---

## Monitoring & Reporting

### Test Results
- **Location:** `fastlane/test_output/`
- **Formats:** HTML, JUnit XML
- **Retention:** 30 days on GitHub Actions

### Code Coverage
- **Location:** `fastlane/test_output/coverage/`
- **Minimum:** 60%
- **Format:** HTML report via xcov

### Screenshots (UI Tests)
- **Location:** `fastlane/screenshots/`
- **Captured:** On test failures
- **Retention:** 7 days on GitHub Actions

---

## Best Practices

### 1. **Commit Frequently**
- Run `bundle exec fastlane unit_tests` before each commit
- Full `bundle exec fastlane ci` before pushing

### 2. **Keep Tests Fast**
- Unit tests should run < 5 minutes
- UI tests should run < 10 minutes
- Parallelize where possible

### 3. **Monitor Coverage**
- Aim for > 60% overall coverage
- Critical paths should have > 80% coverage
- Add tests before fixing bugs

### 4. **Review CI Failures**
- Check logs immediately
- Don't merge PRs with failing tests
- Fix flaky tests promptly

### 5. **Update Dependencies**
```bash
# Update Fastlane
bundle update fastlane

# Update all gems
bundle update
```

---

## GitHub Actions Setup Checklist

- [ ] Repository has `.github/workflows/` directory
- [ ] `main.yml` workflow is present
- [ ] `pr.yml` workflow is present
- [ ] Ruby version matches (3.3.5)
- [ ] Xcode version matches (16.0)
- [ ] Simulator name is available on CI runners
- [ ] Repository permissions allow Actions
- [ ] Branch protection rules configured (optional)

---

## Next Steps

### Optional Enhancements

1. **Code Coverage Integration**
   - Setup Codecov account
   - Add `CODECOV_TOKEN` to repository secrets

2. **Slack Notifications**
   - Add Slack webhook to GitHub Actions
   - Notify on build/test failures

3. **Automated Releases**
   - Add TestFlight upload lane
   - Create release workflow

4. **Performance Testing**
   - Add XCTest performance metrics
   - Track regression over time

5. **Deploy to App Store**
   - Add App Store Connect API key
   - Create release automation

---

## Support & Resources

### Documentation
- [Fastlane Docs](https://docs.fastlane.tools)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

### Project Documentation
- [Fastlane README](fastlane/README.md)
- [Project README](README.md)

### Community
- [Fastlane GitHub](https://github.com/fastlane/fastlane)
- [GitHub Actions Community](https://github.community/c/code-to-cloud/52)

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Maintained By:** Development Team

