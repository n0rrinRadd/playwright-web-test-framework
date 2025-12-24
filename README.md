# 🎭 Wordle SDET Challenge (Playwright)

Automated end-to-end testing for [Wordle](https://www.nytimes.com/games/wordle/index.html) using [Playwright](https://playwright.dev/) with **Page Object Model** architecture.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Test Architecture](#test-architecture)
- [Running Tests](#running-tests)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [CI/CD Integration](#cicd-integration)
- [Useful Commands](#useful-commands)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

## 🌟 Overview

This repository contains automated tests for the NY Times Wordle game using **Playwright**, a modern end-to-end testing framework. The tests cover:

- **Modal interactions** (Terms of Service, How to Play)
- **Game board validation** (6 rows × 5 columns)
- **Word entry** (valid and invalid inputs)
- **Error handling** (validation messages)

### Why Playwright?

- ✅ **Cross-browser testing** (Chrome, Firefox, Safari, Edge, Mobile)
- ✅ **Auto-waiting** for elements
- ✅ **Parallel execution** out of the box
- ✅ **Built-in test artifacts** (screenshots, videos, traces)
- ✅ **TypeScript support** with great IDE integration
- ✅ **Better debugging** with Playwright Inspector
- ✅ **Page Object Model** for maintainable test architecture
- ✅ **Mobile testing** with device emulation

## 🔧 Prerequisites

Before you begin, ensure you have:

- **Node.js** (v18 or higher) - [Download here](https://nodejs.org/)
- **npm** package manager (comes with Node.js)

## 📦 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd playwright-web-test-framework
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Install Playwright browsers**:
   ```bash
   npx playwright install --with-deps
   ```

4. **Set up environment variables** (optional):
   ```bash
   cp .env.example .env
   # Edit .env if you need to customize BASE_URL
   ```

> ⚠️ **Note**: The `.env` file is not committed to version control for security.

## 🏗️ Test Architecture

This project follows the **Page Object Model (POM)** design pattern for maintainable and reusable test code:

### Page Object Model Structure

```
tests/
├── wordle.spec.ts      # Test specifications
├── wordle.po.ts        # Page Object (actions & verifications)
└── wordle.lo.ts        # Locators (element selectors)
```

#### **wordle.lo.ts** - Locators Layer
Centralizes all element selectors in one place:
- Modal selectors (ToS, Play button, How to Play)
- Game board selectors (board, rows, tiles)
- Keyboard selectors (letter buttons, enter key)
- Toast message selectors (error notifications)

**Benefits:**
- Single source of truth for all locators
- Easy to update when UI changes
- Reusable across multiple page methods

#### **wordle.po.ts** - Page Object Layer
Contains reusable methods for interacting with the Wordle page:
- `setupGame()` - Navigate, close modals, prepare game
- `enterWord(word)` - Type a word and submit
- `verifyTitle()` - Check page title
- `verifyBoardDimensions()` - Validate 6x5 board structure
- `verifyErrorMessage(text)` - Assert error appears
- `verifyNoErrorMessage(text)` - Assert no error appears

**Benefits:**
- Encapsulates page interactions
- Provides clear, readable test methods
- Includes comprehensive console logging with emojis

#### **wordle.spec.ts** - Test Specifications
Uses `beforeEach` and `afterEach` hooks for test setup:

```typescript
let wordlePage: WordlePage;

test.beforeEach(async ({ page }) => {
    wordlePage = new WordlePage(page);
    await wordlePage.setupGame();
});

test.afterEach(async () => {
    // Cleanup
});
```

**Test Cases:**
1. ✅ Verify modal is closed and board is accessible
2. ✅ Verify page title equals "Wordle - The New York Times"
3. ✅ Verify game board exists with 6 rows × 5 columns
4. ✅ Enter invalid word and verify "Not in word list" error
5. ✅ Enter valid word and verify no error message

## 🚀 Running Tests

### Run all tests (all browsers)
```bash
npm test
```

### Run tests by specific browser
```bash
npm run test:chrome          # Chromium only
npm run test:firefox         # Firefox only
npm run test:safari          # WebKit/Safari only
npm run test:edge            # Microsoft Edge only
npm run test:mobile-chrome   # Mobile Chrome (Pixel 5)
npm run test:mobile-safari   # Mobile Safari (iPhone 12)
```

### Run all browsers sequentially
```bash
npm run test:all-browsers    # All 6 browsers one after another
```

### Run tests in headed mode
```bash
npm run test:headed          # See the browser while tests run
```

### Run tests in UI mode
```bash
npm run test:ui              # Interactive UI mode for debugging
```

### Debug tests
```bash
npm run test:debug           # Step through tests with debugger
```

### View test report
```bash
npm run test:report          # Open HTML test report
```

### Generate test code
```bash
npm run test:codegen         # Codegen tool to record actions
```

### Advanced: Run specific test file or pattern
```bash
npx playwright test tests/wordle.spec.ts                    # Specific file
npx playwright test --grep "should display correct title"  # By test name
npx playwright test --project=firefox tests/wordle.spec.ts  # Specific browser + file
```

## 🔄 CI/CD Integration

### GitHub Actions

#### On-Demand Test Execution
The **test-by-browser.yml** workflow provides flexible on-demand test execution with:

- **Multi-checkbox browser selection**: Select one or more browsers to test
  - 🌐 Chromium
  - 🦊 Firefox
  - 🧭 WebKit (Safari)
  - 🔷 Edge
  - 📱 Mobile Chrome (Pixel 5 emulation)
  - 📱 Mobile Safari (iPhone 12 emulation)
  - 🎭 All Browsers (default)

#### Workflow Features

**Test Execution:**
- ✅ **Sequential browser execution**: When "All Browsers" is selected, runs one browser at a time
- ✅ **Independent browser jobs**: When selecting individual browsers, only those browsers run
- ✅ **Continue on failure**: If one browser fails, remaining browsers still execute
- ✅ **60-minute timeout** per browser job

**Test Results & Reporting:**
- ✅ **Artifact uploads**: Playwright HTML reports, JUnit XML results, videos, screenshots
- ✅ **30-day artifact retention**
- ✅ **Test results available in Actions tab**

**Runner Configuration:**
- Runs on `ubuntu-latest` runner
- Node.js 20 LTS
- Supports both `workflow_dispatch` (manual) and `workflow_call` (reusable) triggers

**Environment Variables:**
- Uses `BASE_URL` from GitHub Variables or defaults to Wordle URL
- Configured at workflow level for consistency

### Automated Triggers
GitHub Actions will run automatically on:
- ✅ **Pull Requests** - Validates changes before merge
- ✅ **Pushes to main** - Ensures main branch stability
- ✅ **Schedule** - Nightly runs at 00:30 UTC

### Manual Execution

1. Go to the **Actions** tab in GitHub
2. Select the workflow you want to run:
   - **On-Demand Run Tests by Browser** - Run specific browsers
   - **Run UI Tests** - Run all tests
3. Click **Run workflow**
4. Select the branch to run from
5. (For browser workflow) Check the browsers to test

### Available Workflows

#### **test-by-browser.yml** - Multi-Browser Testing
- 🎯 Select specific browsers to test
- ✅ Input validation (prevents empty runs)
- 🔄 Sequential execution (one browser at a time)
- 📊 Separate reports per browser
- 🌐 Supported browsers:
  - Chromium
  - Firefox
  - WebKit (Safari)
  - Microsoft Edge
  - Mobile Chrome
  - Mobile Safari

#### **Nightly Workflows**
Individual workflows for each browser:
- `nightly-chromium.yml`
- `nightly-firefox.yml`
- `nightly-webkit.yml`
- `nightly-edge.yml`
- `nightly-mobile-chrome.yml`
- `nightly-mobile-safari.yml`

Each runs on its own schedule and uses the `test-by-browser.yml` workflow.

### CI Configuration
Tests run on **Ubuntu-latest** with:
- Node.js LTS version
- Playwright with browser dependencies (`--with-deps`)
- Automatic artifact upload:
  - Test reports (HTML)
  - Test results (JUnit XML)
  - Videos (on failure)
  - Screenshots (on failure)

### Required GitHub Configuration

**Variables** (Settings → Secrets and variables → Actions → Variables):
- `BASE_URL` (optional - defaults to Wordle URL)

## 📁 Project Structure

```
playwright-web-test-framework/
├── .github/
│   └── workflows/
│       ├── test-by-browser.yml      # Multi-browser on-demand workflow
│       ├── nightly-*.yml            # Individual browser schedules
│       ├── on_push.yml              # Runs on push to main
│       └── on_pull_request.yml      # Runs on PRs
├── tests/
│   ├── wordle.spec.ts               # Test specifications
│   ├── wordle.po.ts                 # Page Object (methods)
│   └── wordle.lo.ts                 # Locators (selectors)
├── playwright.config.ts             # Playwright configuration
├── package.json                     # Dependencies & scripts
├── .env                             # Environment variables (BASE_URL)
└── README.md                        # This file
```

## ⚙️ Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
BASE_URL=https://www.nytimes.com/games/wordle/index.html
```

### Playwright Config
The `playwright.config.ts` includes:
- **Base URL:** Loaded from `.env` file (defaults to Wordle URL)
- **Browsers:** Chromium, Firefox, WebKit, Edge, Mobile Chrome, Mobile Safari
- **Parallel execution:** Enabled by default (`fullyParallel: true`)
- **Workers:** 4 in CI, unlimited locally (Edge runs with 1 worker for stability)
- **Retries:** 1 retry in CI, 0 locally (Edge has 1 retry for flakiness)
- **Timeouts:** Standard 30s (Edge has extended 60s timeouts)
- **Artifacts:** Videos, screenshots, traces on failure only
- **Reporters:** List, Blob, JUnit XML, HTML (does not auto-open)

## 🛠 Useful Commands

| Task | Command | Description |
| :--- | :--- | :--- |
| **Run all tests** | `npm test` | Run all tests in all browsers |
| **Run Chromium** | `npm run test:chrome` | Chromium only |
| **Run Firefox** | `npm run test:firefox` | Firefox only |
| **Run Safari** | `npm run test:safari` | WebKit/Safari only |
| **Run Edge** | `npm run test:edge` | Microsoft Edge only |
| **Run Mobile Chrome** | `npm run test:mobile-chrome` | Pixel 5 emulation |
| **Run Mobile Safari** | `npm run test:mobile-safari` | iPhone 12 emulation |
| **Run all browsers** | `npm run test:all-browsers` | Sequential execution (all 6 browsers) |
| **Headed mode** | `npm run test:headed` | See browser while running |
| **UI mode** | `npm run test:ui` | Interactive debugging UI |
| **Debug tests** | `npm run test:debug` | Step-through debugger |
| **View report** | `npm run test:report` | Open HTML report |
| **Generate code** | `npm run test:codegen` | Record actions as code |
| **Specific file** | `npx playwright test tests/wordle.spec.ts` | Run one test file |
| **Specific test** | `npx playwright test --grep "title"` | Run tests matching pattern |

## 🐛 Troubleshooting

### Tests failing due to timeouts
- Increase timeout in `playwright.config.ts`
- Check network connectivity
- Verify the NY Times Wordle site is accessible
- The daily Wordle puzzle must be available

### Element not found errors
- Use Playwright Inspector: `npm run test:debug`
- Check page object locators in `tests/wordle.lo.ts`
- Update locator class if Wordle UI changed
- Ensure modals are properly closed before interacting with the board

### Edge-specific issues
- Edge tests run serially (1 worker) for session stability
- Edge has longer timeouts (60s) compared to other browsers
- Edge tests may be flaky and have 1 automatic retry

### Screenshots/videos not generated
- Check `playwright.config.ts` settings
- Ensure `screenshot: 'only-on-failure'` and `video: 'retain-on-failure'` are set
- Look in `test-results/` directory after test failures

### Modal handling issues
- ToS modal appears conditionally - the page object handles this gracefully
- "How to Play" modal may take time to appear - built-in waits handle this
- Check console logs for modal interaction steps (emojis help track progress)

### Word entry issues
- Ensure the keyboard is visible before entering words
- Some words may not be in Wordle's dictionary (use common 5-letter words)
- The Enter button must be clicked after typing all 5 letters

## 📚 Resources

- [Playwright Documentation](https://playwright.dev)
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Playwright API Reference](https://playwright.dev/docs/api/class-playwright)
- [Wordle Game](https://www.nytimes.com/games/wordle/index.html)
- [VS Code Playwright Extension](https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright)
- [Page Object Model Pattern](https://playwright.dev/docs/pom)

---

**Happy Testing! 🎭**

# playwright-web-test-framework
