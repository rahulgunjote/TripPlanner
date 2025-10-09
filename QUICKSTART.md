# Quick Start - CI/CD Setup

## 🚀 Get Started in 5 Minutes

### Step 1: Install Ruby 3.3.5

```bash
# Using rbenv (recommended)
brew install rbenv
rbenv install 3.3.5
rbenv local 3.3.5

# Verify
ruby -v  # Should show: ruby 3.3.5
```

### Step 2: Install Dependencies

```bash
cd /path/to/TripPlanner
gem install bundler
bundle install
```

### Step 3: Run Your First Lane

```bash
# Build the project
bundle exec fastlane build

# Run unit tests
bundle exec fastlane unit_tests

# Run full CI pipeline
bundle exec fastlane ci
```

---

## 📝 Available Commands

### Quick Testing
```bash
bundle exec fastlane unit_tests    # Fast unit tests
bundle exec fastlane ui_tests      # UI tests
bundle exec fastlane test          # All tests
```

### Before Committing
```bash
bundle exec fastlane build         # Verify build
bundle exec fastlane unit_tests    # Quick tests
```

### Before Pushing
```bash
bundle exec fastlane ci            # Full pipeline
```

---

## 🔧 GitHub Actions

### Automatic Runs

**Main Branch:**
- Triggers: Push to `main`
- Runs: Build + All Tests
- Reports: Coverage + Test Results

**Pull Requests:**
- Triggers: PR to `main` or `develop`
- Runs: Build Check + Unit Tests + UI Tests (parallel)
- Reports: Test Results + Screenshots (if failed)

### No Setup Required!

GitHub Actions will automatically run when you:
1. Push to `main` branch
2. Create or update a Pull Request

---

## 📊 Where to Find Results

### Local
- Test Reports: `fastlane/test_output/`
- HTML Report: `fastlane/test_output/report.html`

### GitHub Actions
- Go to: Repository → Actions tab
- View workflow runs and download artifacts

---

## 🆘 Quick Troubleshooting

### "Ruby version doesn't match"
```bash
rbenv install 3.3.5
rbenv local 3.3.5
bundle install
```

### "Simulator not found"
```bash
# List available simulators
xcrun simctl list devices available

# Update Fastfile with your simulator name
# Edit: fastlane/Fastfile, line: SIMULATOR = "YOUR_SIMULATOR"
```

### "Build failed"
```bash
bundle exec fastlane clean
rm -rf ~/Library/Developer/Xcode/DerivedData
```

---

## 📚 Full Documentation

See [CICD_SETUP.md](CICD_SETUP.md) for complete documentation.

---

**Happy Testing! 🎉**

