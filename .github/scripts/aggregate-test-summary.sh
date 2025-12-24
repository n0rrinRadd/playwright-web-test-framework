#!/bin/bash

# Script to generate aggregated test summary from all browser test results
# This runs after all browser tests complete

echo "## 🎭 Aggregated Test Results - All Browsers" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0
TOTAL_RETRIES=0

# Array of browser names
BROWSERS=("chromium" "firefox" "webkit" "edge" "mobile-chrome" "mobile-safari")
BROWSER_EMOJIS=("🌐" "🦊" "🧭" "🔷" "📱" "📱")
BROWSER_NAMES=("Chromium" "Firefox" "WebKit" "Edge" "Mobile Chrome" "Mobile Safari")

echo "| Browser | ✅ Passed | ❌ Failed | ⏭️ Skipped | 📊 Total |" >> $GITHUB_STEP_SUMMARY
echo "|---------|----------|----------|-----------|---------|" >> $GITHUB_STEP_SUMMARY

# Process each browser's results
for i in "${!BROWSERS[@]}"; do
  browser="${BROWSERS[$i]}"
  emoji="${BROWSER_EMOJIS[$i]}"
  name="${BROWSER_NAMES[$i]}"
  
  # Check if this browser's artifact directory exists
  if [ -d "$browser" ] && [ -f "$browser/test-results.xml" ]; then
    TESTS=$(grep -o 'tests="[0-9]*"' "$browser/test-results.xml" | head -1 | grep -o '[0-9]*')
    FAILURES=$(grep -o 'failures="[0-9]*"' "$browser/test-results.xml" | head -1 | grep -o '[0-9]*')
    SKIPPED=$(grep -o 'skipped="[0-9]*"' "$browser/test-results.xml" | head -1 | grep -o '[0-9]*' || echo "0")
    PASSED=$((TESTS - FAILURES - SKIPPED))
    
    echo "| $emoji $name | $PASSED | $FAILURES | $SKIPPED | $TESTS |" >> $GITHUB_STEP_SUMMARY
    
    TOTAL_TESTS=$((TOTAL_TESTS + TESTS))
    TOTAL_PASSED=$((TOTAL_PASSED + PASSED))
    TOTAL_FAILED=$((TOTAL_FAILED + FAILURES))
    TOTAL_SKIPPED=$((TOTAL_SKIPPED + SKIPPED))
    
    # Count retries
    if [ -d "$browser/test-results" ]; then
      RETRIES=$(find "$browser/test-results" -name "*retry*" -type d 2>/dev/null | wc -l | tr -d ' ')
      TOTAL_RETRIES=$((TOTAL_RETRIES + RETRIES))
    fi
  else
    echo "| $emoji $name | - | - | - | ⚠️ No results |" >> $GITHUB_STEP_SUMMARY
  fi
done

echo "|---------|----------|----------|-----------|---------|" >> $GITHUB_STEP_SUMMARY
echo "| **📊 TOTAL** | **$TOTAL_PASSED** | **$TOTAL_FAILED** | **$TOTAL_SKIPPED** | **$TOTAL_TESTS** |" >> $GITHUB_STEP_SUMMARY

echo "" >> $GITHUB_STEP_SUMMARY
echo "### 📈 Overall Statistics" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

if [ $TOTAL_TESTS -gt 0 ]; then
  OVERALL_PASS_PCT=$((TOTAL_PASSED * 100 / TOTAL_TESTS))
  OVERALL_FAIL_PCT=$((TOTAL_FAILED * 100 / TOTAL_TESTS))
  
  echo "- **Total Tests Executed**: $TOTAL_TESTS" >> $GITHUB_STEP_SUMMARY
  echo "- **Pass Rate**: ${OVERALL_PASS_PCT}%" >> $GITHUB_STEP_SUMMARY
  echo "- **Fail Rate**: ${OVERALL_FAIL_PCT}%" >> $GITHUB_STEP_SUMMARY
  echo "- **Total Retries**: $TOTAL_RETRIES" >> $GITHUB_STEP_SUMMARY
  
  # Visual progress bar
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "### 📊 Overall Progress" >> $GITHUB_STEP_SUMMARY
  PASS_BLOCKS=$((TOTAL_PASSED * 20 / TOTAL_TESTS))
  FAIL_BLOCKS=$((TOTAL_FAILED * 20 / TOTAL_TESTS))
  SKIP_BLOCKS=$((TOTAL_SKIPPED * 20 / TOTAL_TESTS))
  
  echo -n "🟢" >> $GITHUB_STEP_SUMMARY
  for i in $(seq 1 $PASS_BLOCKS); do echo -n "█" >> $GITHUB_STEP_SUMMARY; done
  echo -n "🔴" >> $GITHUB_STEP_SUMMARY
  for i in $(seq 1 $FAIL_BLOCKS); do echo -n "█" >> $GITHUB_STEP_SUMMARY; done
  if [ $TOTAL_SKIPPED -gt 0 ]; then
    echo -n "⚪" >> $GITHUB_STEP_SUMMARY
    for i in $(seq 1 $SKIP_BLOCKS); do echo -n "█" >> $GITHUB_STEP_SUMMARY; done
  fi
  echo "" >> $GITHUB_STEP_SUMMARY
else
  echo "⚠️ No test results found" >> $GITHUB_STEP_SUMMARY
fi
