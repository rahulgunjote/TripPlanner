# 🚀 Launchable Setup Guide - TripPlanner

## Overview

Launchable is an ML-powered predictive test selection platform that intelligently determines which tests to run based on code changes, historical test data, and failure patterns.

---

## 🎯 Benefits

### Time Savings
- **Up to 75% faster CI**: Run only tests likely to fail
- **Smart prioritization**: Critical tests run first
- **Flaky test detection**: Identify and handle unreliable tests

### Machine Learning
- **Predictive analytics**: Learn from historical test data
- **Failure prediction**: Run tests most likely to catch bugs
- **Continuous improvement**: Gets smarter over time

### Better Insights
- **Test impact analysis**: See which tests matter for your changes
- **Performance tracking**: Monitor test execution trends
- **Flaky test reports**: Identify problematic tests

---

## 📋 Prerequisites

1. **Launchable Account**
   - Sign up at [https://www.launchableinc.com](https://www.launchableinc.com)
   - Free for open source projects
   - Paid plans for private repositories

2. **Python 3.7+**
   - Required for Launchable CLI
   - Usually pre-installed on macOS and GitHub Actions

3. **Git History**
   - Full git history for better predictions
   - Ensure `fetch-depth: 0` in GitHub Actions

---

## 🔧 Setup Instructions

### Step 1: Create Launchable Account

1. Go to [https://app.launchableinc.com/signup](https://app.launchableinc.com/signup)
2. Sign up with GitHub account
3. Create an organization (e.g., "TripPlanner")
4. Create a workspace for your project

### Step 2: Get API Token

1. In Launchable dashboard, go to Settings → API Tokens
2. Click "Create Token"
3. Copy your token (format: `organization/workspace:token`)
4. Store it securely

### Step 3: Add Token to GitHub

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Name: `LAUNCHABLE_TOKEN`
5. Value: Your Launchable token
6. Click "Add secret"

### Step 4: Install Dependencies

```bash
# Install Launchable CLI (Python package)
# Option 1: Using pipx (recommended for local development)
brew install pipx
pipx install launchable

# Option 2: Using pip3 with user flag
pip3 install --user launchable

# Option 3: Using virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip3 install launchable

# Option 4: Break system packages (CI only - not recommended locally)
pip3 install --upgrade --break-system-packages launchable

# Install Ruby dependencies
bundle install
```

**Note**: Launchable is a Python CLI tool, not a Ruby gem. For local development, use `pipx` or `--user` flag. In CI (GitHub Actions), we use `--break-system-packages` since runners are ephemeral.

### Step 5: Verify Setup

```bash
# Set your token
export LAUNCHABLE_TOKEN="your-organization/workspace:your-token"

# Verify authentication
bundle exec fastlane launchable_verify
```

---

## 🚀 Usage

### Local Testing

#### Test Launchable Setup
```bash
export LAUNCHABLE_TOKEN="your-token"
bundle exec fastlane launchable_verify
```

#### Record Build
```bash
bundle exec fastlane launchable_record_build
```

#### Run Intelligent Tests
```bash
bundle exec fastlane launchable_test
```

#### Run with Custom Target Time
```bash
# Target 5 minutes of test time
launchable subset --target 5m xcode
```

### GitHub Actions (Automatic)

Launchable runs automatically on all PRs:

1. **Build Recording**: Tracks each build
2. **Test Discovery**: Finds all available tests
3. **Subset Selection**: Picks optimal tests to run
4. **Test Execution**: Runs selected tests
5. **Results Upload**: Sends results to Launchable
6. **Insights**: Comments on PR with test strategy

---

## 📊 Launchable Workflow

### How It Works

```
1. Code Change (PR)
   ↓
2. Record Build
   ↓
3. Discover Tests
   ↓
4. ML Analysis
   • Historical data
   • Code changes
   • Test patterns
   • Failure rates
   ↓
5. Select Subset (~30% of tests)
   ↓
6. Run Selected Tests
   ↓
7. Upload Results
   ↓
8. Learn & Improve
```

### Subset Selection Strategy

Launchable considers:
- **Code changes**: Which files were modified
- **Test history**: Which tests failed recently
- **Impact analysis**: Which tests cover changed code
- **Flaky tests**: Prioritize reliable tests
- **Execution time**: Balance speed vs coverage

---

## 🎛️ Configuration

### .launchable.yml

Basic configuration:
```yaml
version: 1
test_framework: xcode
subset:
  target: 180  # 3 minutes
  confidence: 90  # 90% confidence
  fallback: full  # Run all if subset fails
```

### Target Time

Adjust based on your needs:
```yaml
subset:
  target: 60   # Fast feedback (1 minute)
  target: 180  # Balanced (3 minutes)
  target: 300  # Comprehensive (5 minutes)
```

### Confidence Level

Higher = more tests, safer:
```yaml
subset:
  confidence: 75  # Aggressive (fewer tests)
  confidence: 90  # Balanced (recommended)
  confidence: 95  # Conservative (more tests)
```

---

## 📈 Interpreting Results

### PR Comments

Example:
```
🧠 Launchable Intelligent Testing

Selected 15 tests (30% of total)
Estimated time: 2m 45s
Predicted failure detection: 95%

Tests selected:
  • TripViewModelTests (high priority)
  • ExpenseViewModelTests (code changed)
  • TripListUITests (flaky - running for stability)

View detailed insights on Launchable
```

### Dashboard Metrics

On [app.launchableinc.com](https://app.launchableinc.com):
- **Subset efficiency**: % of tests saved
- **Failure detection rate**: % of failures caught
- **Time savings**: Minutes saved per PR
- **Flaky test report**: Tests with reliability issues

---

## 🔄 Launchable Lanes

### launchable_verify
**Purpose**: Verify Launchable setup

**Usage**:
```bash
bundle exec fastlane launchable_verify
```

**Checks**:
- CLI installed
- Token configured
- Authentication working

---

### launchable_record_build
**Purpose**: Record build for tracking

**Usage**:
```bash
bundle exec fastlane launchable_record_build
```

**When**: Before running tests

---

### launchable_subset_test
**Purpose**: Run intelligent test subset

**Usage**:
```bash
bundle exec fastlane launchable_subset_test
```

**Process**:
1. Records test session
2. Discovers available tests
3. Gets optimized subset
4. Runs selected tests
5. Uploads results

---

### launchable_test
**Purpose**: Run with automatic fallback

**Usage**:
```bash
bundle exec fastlane launchable_test
```

**Safety**: Falls back to full suite if Launchable fails

---

## 🛡️ Safety Features

### Automatic Fallback

If Launchable fails:
1. Logs the error
2. Runs full test suite
3. Continues CI/CD pipeline
4. No interruption to workflow

### Full Suite Option

Force full test suite:
```bash
bundle exec fastlane test
```

### Session Tracking

Every test run is tracked:
- Unique session ID
- Build information
- Test results
- Execution time

---

## 📊 Advanced Features

### Flaky Test Detection

Launchable automatically identifies flaky tests:
- Tracks test stability over time
- Flags inconsistent tests
- Provides reliability scores
- Suggests tests to fix or quarantine

### Test Impact Analysis

See which tests are affected by your changes:
```bash
launchable inspect tests --session <session-id>
```

### Historical Analysis

View trends over time:
- Test duration trends
- Failure rate patterns
- Coverage evolution
- Subset effectiveness

### Custom Test Prioritization

Override ML decisions:
```bash
launchable subset \
  --target 3m \
  --priority high \
  --confidence 95 \
  xcode
```

---

## 🔍 Troubleshooting

### Issue: Launchable CLI not found

**Solution**:
```bash
# Recommended: Use pipx
brew install pipx
pipx install launchable

# Alternative: Install with --user flag
pip3 install --user launchable

# Alternative: Use virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip3 install launchable

# Verify installation
which launchable
launchable --version
```

**Common causes**:
- Python not in PATH
- pip3 not installed
- Virtual environment not activated
- Installed with --user but ~/.local/bin not in PATH

### Issue: "externally-managed-environment" error

**Problem**: Python 3.11+ on macOS protects system packages (PEP 668)

**Solutions**:

**Local Development (recommended)**:
```bash
# Option 1: Use pipx (best for CLI tools)
brew install pipx
pipx install launchable

# Option 2: Use --user flag
pip3 install --user launchable
# Add to PATH if needed:
export PATH="$HOME/.local/bin:$PATH"

# Option 3: Use virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip3 install launchable
```

**CI/CD Only**:
```bash
# Safe in CI since runners are ephemeral
pip3 install --break-system-packages launchable
```

### Issue: Authentication failed

**Solution**:
```bash
# Check token format
echo $LAUNCHABLE_TOKEN
# Should be: organization/workspace:token

# Verify with Launchable
launchable verify
```

### Issue: No tests in subset

**Possible causes**:
1. First run (no historical data)
2. Target time too low
3. All tests recently passed

**Solution**:
- Wait for more data to accumulate
- Increase target time
- Run full suite initially

### Issue: Subset takes longer than expected

**Solution**:
- Adjust target time
- Lower confidence level
- Report slow tests to Launchable

---

## 💡 Best Practices

### 1. Start Conservative

```yaml
subset:
  target: 300  # 5 minutes initially
  confidence: 95
```

Gradually reduce as you gain confidence.

### 2. Track Metrics

Monitor on Launchable dashboard:
- Subset efficiency (target: >50%)
- Failure detection (target: >90%)
- Time savings (track trend)

### 3. Handle Flaky Tests

- Review flaky test reports weekly
- Fix or quarantine unreliable tests
- Track improvement over time

### 4. Full Suite on Main

```yaml
# main.yml
- name: Run Full Test Suite
  run: bundle exec fastlane test  # No subset
```

Always run full suite on main branch.

### 5. Let ML Learn

- Run for 2-4 weeks before judging
- More data = better predictions
- Continuous improvement

---

## 📈 Expected Results

### Week 1: Learning Phase
- Subset: 60-80% of tests
- Time saved: 10-20%
- ML building baseline

### Week 2-4: Optimization
- Subset: 40-60% of tests
- Time saved: 30-50%
- ML improving predictions

### Week 4+: Mature
- Subset: 20-40% of tests
- Time saved: 50-75%
- High confidence predictions

---

## 🔗 Integration with Other Tools

### Codecov Integration

```bash
# After Launchable tests
bundle exec fastlane coverage
# Coverage data will include subset results
```

### Slack Notifications

Add to Fastfile:
```ruby
lane :launchable_test do
  # ... launchable test logic
  
  slack(
    message: "Launchable tests completed: #{subset_count} tests run",
    success: true
  )
end
```

### Custom Webhooks

Send Launchable data to your analytics:
```ruby
# Parse Launchable output and send to your system
```

---

## 📚 Resources

### Documentation
- [Launchable Docs](https://www.launchableinc.com/docs)
- [Xcode Integration](https://www.launchableinc.com/docs/resources/xcode)
- [CLI Reference](https://www.launchableinc.com/docs/cli)

### Support
- [Launchable Support](https://support.launchableinc.com)
- [Community Slack](https://launchable-community.slack.com)
- [GitHub Examples](https://github.com/launchableinc/examples)

### Pricing
- [Pricing Plans](https://www.launchableinc.com/pricing)
- Free tier available
- Open source discount

---

## 🎯 Success Metrics

Track these KPIs:

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Time Savings | >50% | Launchable dashboard |
| Failure Detection | >90% | Test results vs subset |
| Subset Size | 20-40% | Tests run vs total |
| False Negatives | <5% | Failures caught in main |
| ROI | Positive | Time saved × developer cost |

---

## 🚦 Migration Checklist

- [ ] Create Launchable account
- [ ] Get API token
- [ ] Add token to GitHub secrets
- [ ] Install Launchable CLI locally
- [ ] Verify setup with `launchable_verify`
- [ ] Test locally with `launchable_test`
- [ ] Update PR workflow
- [ ] Monitor first few PRs
- [ ] Adjust confidence/target as needed
- [ ] Review metrics after 2 weeks
- [ ] Document learnings

---

## 🤝 Support

For issues:
1. Check Launchable dashboard for insights
2. Review GitHub Actions logs
3. Run `launchable_verify` locally
4. Contact Launchable support if needed

---

**Version**: 1.0.0  
**Last Updated**: October 2025  
**Maintained By**: Development Team  
**Launchable Version**: 2.0+

