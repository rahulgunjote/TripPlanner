# CI/CD Architecture - TripPlanner

## 🏗️ System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      TripPlanner CI/CD                       │
│                                                              │
│  Fastlane (Local & CI) + GitHub Actions (Cloud CI)          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DEVELOPER MACHINE                            │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Local Development                          │  │
│  │                                                               │  │
│  │  Code Changes → Run Fastlane Lanes → Verify → Commit        │  │
│  │                                                               │  │
│  │  Available Lanes:                                            │  │
│  │  • bundle exec fastlane build                                │  │
│  │  • bundle exec fastlane unit_tests                           │  │
│  │  • bundle exec fastlane ui_tests                             │  │
│  │  • bundle exec fastlane ci (full pipeline)                   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              ↓                                       │
└──────────────────────────────┼───────────────────────────────────────┘
                               │
                               ↓
                        ┌──────────────┐
                        │  Git Push    │
                        └──────────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ↓                             ↓
        ┌───────────────┐            ┌───────────────┐
        │  Push to Main │            │  Pull Request │
        └───────────────┘            └───────────────┘
                │                             │
                ↓                             ↓
┌───────────────────────────┐    ┌───────────────────────────────┐
│  Main Workflow (.yml)     │    │  PR Workflow (.yml)           │
│                           │    │                               │
│  Triggers: Push to main   │    │  Triggers: PR to main/develop │
│                           │    │                               │
│  Steps:                   │    │  Jobs (Parallel):             │
│  1. Setup Environment     │    │  1. Build Check               │
│  2. Build Project         │    │  2. Unit Tests                │
│  3. Run Unit Tests        │    │  3. UI Tests (after #2)       │
│  4. Run UI Tests          │    │                               │
│  5. Upload Results        │    │  Features:                    │
│  6. Upload Coverage       │    │  • Parallel execution         │
│  7. Comment on Commit     │    │  • PR comments                │
│                           │    │  • Artifact uploads           │
└───────────────────────────┘    └───────────────────────────────┘
                │                             │
                └──────────────┬──────────────┘
                               │
                               ↓
                    ┌─────────────────────┐
                    │   Test Results      │
                    │   • HTML Reports    │
                    │   • JUnit XML       │
                    │   • Screenshots     │
                    │   • Coverage Data   │
                    └─────────────────────┘
```

---

## 🔄 Workflow Details

### Main Branch Workflow

```
Push to main
    │
    ├─► Setup (macOS 15, Xcode 16.0, Ruby 3.3.5)
    │
    ├─► Install Dependencies (bundle install)
    │
    ├─► Build Project (fastlane build)
    │   └─► Clean Build
    │       └─► Compile Sources
    │           └─► Link Binaries
    │
    ├─► Run Unit Tests (fastlane unit_tests)
    │   ├─► TripViewModelTests
    │   ├─► TravellerViewModelTests
    │   ├─► ItineraryViewModelTests
    │   ├─► ExpenseViewModelTests
    │   └─► TripModelTests
    │
    ├─► Run UI Tests (fastlane ui_tests)
    │   ├─► TripPlannerUITests
    │   ├─► TripFlowUITests
    │   ├─► TravellerFlowUITests
    │   └─► ItineraryAndExpenseUITests
    │
    ├─► Generate Artifacts
    │   ├─► HTML Test Report
    │   ├─► JUnit XML
    │   └─► Code Coverage
    │
    └─► Upload & Notify
        ├─► Upload to Artifacts (30 days)
        ├─► Upload to Codecov
        └─► Comment on Commit
```

### Pull Request Workflow

```
Create/Update PR
    │
    ├─────────────┬─────────────┬────────────►
    │             │             │
    ▼             ▼             ▼
┌────────┐   ┌───────┐   ┌────────────┐
│ Build  │   │ Unit  │   │ UI Tests   │
│ Check  │   │ Tests │   │ (Sequential)│
└────────┘   └───────┘   └────────────┘
    │             │             │
    │             │             │ (waits for unit tests)
    │             │             │
    ▼             ▼             ▼
┌────────┐   ┌───────┐   ┌────────────┐
│Comment │   │Upload │   │   Upload   │
│on PR   │   │Results│   │   Results  │
│        │   │       │   │     +      │
│✅ Build│   │✅Unit │   │Screenshots │
│Success │   │ Pass  │   │            │
└────────┘   └───────┘   │✅UI Pass   │
                         └────────────┘
```

---

## 🎯 Fastlane Lane Structure

```
fastlane/
├── Fastfile
│   ├── Build Lanes
│   │   ├── build
│   │   └── build_for_testing
│   │
│   ├── Test Lanes
│   │   ├── test
│   │   ├── unit_tests
│   │   ├── ui_tests
│   │   └── test_without_building
│   │
│   ├── Quality Lanes
│   │   ├── coverage
│   │   └── lint
│   │
│   └── CI Lanes
│       ├── ci (full pipeline)
│       └── clean
│
├── Appfile (App configuration)
├── Pluginfile (Plugin management)
└── README.md (Documentation)
```

---

## 🔧 Configuration Files

```
Project Root
├── Gemfile (Ruby gems)
├── .ruby-version (3.3.5)
├── .gitignore (Git exclusions)
├── .swiftlint.yml (Lint rules)
├── .xcovignore (Coverage exclusions)
│
├── fastlane/
│   ├── Fastfile
│   ├── Appfile
│   └── Pluginfile
│
├── .github/
│   └── workflows/
│       ├── main.yml
│       └── pr.yml
│
└── Docs/
    ├── CICD_SETUP.md
    ├── CICD_ARCHITECTURE.md (this file)
    └── QUICKSTART.md
```

---

## 🚦 Test Execution Flow

### Unit Tests Flow
```
Build for Testing
    ↓
Load Test Bundle
    ↓
Initialize Test Environment
    ↓
For Each Test Suite:
    ├─► TripViewModelTests
    │   ├─► Setup (ModelContext)
    │   ├─► Run Tests (20+ tests)
    │   └─► Teardown
    │
    ├─► TravellerViewModelTests
    │   ├─► Setup
    │   ├─► Run Tests (15+ tests)
    │   └─► Teardown
    │
    └─► ... (other test suites)
    ↓
Generate Report
    ├─► Success/Failure Status
    ├─► Coverage Data
    └─► Execution Time
```

### UI Tests Flow
```
Build for Testing
    ↓
Launch Simulator
    ↓
Install App
    ↓
For Each Test Suite:
    ├─► TripPlannerUITests
    │   ├─► Launch App
    │   ├─► Test Tab Navigation
    │   ├─► Test Trip List
    │   └─► Capture Screenshots (on failure)
    │
    ├─► TripFlowUITests
    │   ├─► Test Create Trip
    │   ├─► Test Trip Detail
    │   └─► Test Swipe Actions
    │
    └─► ... (other UI test suites)
    ↓
Generate Report
    ├─► Screenshots
    ├─► Video (if enabled)
    └─► Test Results
```

---

## 📈 Performance Characteristics

### Typical Execution Times

| Stage | Local | GitHub Actions |
|-------|-------|----------------|
| Setup | - | ~2 minutes |
| Build | ~30 seconds | ~1 minute |
| Unit Tests | ~10 seconds | ~20 seconds |
| UI Tests | ~2 minutes | ~3 minutes |
| **Total** | **~3 minutes** | **~6-7 minutes** |

### Optimization Strategies

1. **Build Caching:** Bundler cache in GitHub Actions
2. **Parallel Execution:** Unit and Build checks run in parallel
3. **Sequential UI Tests:** Only run after unit tests pass
4. **Selective Testing:** Run unit tests first (fail fast)

---

## 🔐 Security & Best Practices

### Secrets Management
```
GitHub Repository
    └── Settings
        └── Secrets and variables
            └── Actions
                ├── CODECOV_TOKEN (optional)
                ├── SLACK_WEBHOOK (optional)
                └── APP_STORE_CONNECT_KEY (future)
```

### Branch Protection Rules (Recommended)
```
main branch:
    ├── Require PR reviews
    ├── Require status checks
    │   ├── build-check
    │   ├── unit-tests
    │   └── ui-tests
    ├── Require up-to-date branch
    └── Include administrators
```

---

## 🎨 CI/CD Pipeline Philosophy

### Design Principles

1. **Fast Feedback:** Unit tests run first (fail fast)
2. **Parallel Execution:** Independent jobs run simultaneously
3. **Comprehensive Coverage:** Unit + UI + Build checks
4. **Artifact Preservation:** 30-day retention for debugging
5. **Developer Experience:** Clear PR comments and reports

### Lane Organization

```
Build → Test → Report
  ↓       ↓       ↓
Fast   Reliable  Actionable
```

---

## 🔄 Integration Points

### Current Integrations
- ✅ GitHub Actions (CI/CD)
- ✅ Xcode Build System
- ✅ Swift Testing Framework
- ✅ XCTest UI Testing

### Future Integrations (Optional)
- [ ] Codecov (Coverage reporting)
- [ ] Slack (Build notifications)
- [ ] TestFlight (Beta distribution)
- [ ] App Store Connect (Release automation)
- [ ] Danger (PR automation)
- [ ] SonarQube (Code quality)

---

## 📊 Monitoring & Alerts

### Available Metrics

1. **Build Success Rate:** Track via GitHub Actions
2. **Test Pass Rate:** Per test suite metrics
3. **Code Coverage:** HTML reports + Codecov
4. **Build Time:** GitHub Actions timing
5. **Test Execution Time:** Scan reports

### Alert Channels

1. **Email:** GitHub notifications
2. **PR Comments:** Automatic test results
3. **Status Badges:** README integration
4. **Slack:** Custom webhook (optional)

---

## 🎯 Success Criteria

### CI Pipeline Success
```
✅ All builds pass
✅ All unit tests pass (20+ tests)
✅ All UI tests pass (50+ tests)
✅ Code coverage > 60%
✅ No linting errors
✅ Artifacts uploaded
```

### PR Workflow Success
```
✅ Build check passes
✅ Unit tests pass
✅ UI tests pass
✅ No merge conflicts
✅ Reviews approved
✅ Up-to-date with base branch
```

---

## 📚 Related Documentation

- [Complete Setup Guide](CICD_SETUP.md)
- [Quick Start Guide](QUICKSTART.md)
- [Fastlane Documentation](fastlane/README.md)
- [Project README](README.md)

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Architecture:** Fastlane + GitHub Actions  
**Platform:** iOS (Xcode 16.0+)

