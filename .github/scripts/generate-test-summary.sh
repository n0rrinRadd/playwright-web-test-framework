#!/bin/bash

# Script to generate Playwright test summary for GitHub Actions
# Usage: ./generate-test-summary.sh "Browser Name" "🎭 Emoji"

BROWSER_NAME="${1:-Browser}"
BROWSER_EMOJI="${2:-🎭}"

echo "## $BROWSER_EMOJI $BROWSER_NAME Test Results" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

if [ -f "test-results.xml" ]; then
  TOTAL=$(grep -o 'tests="[0-9]*"' test-results.xml | head -1 | grep -o '[0-9]*')
  FAILURES=$(grep -o 'failures="[0-9]*"' test-results.xml | head -1 | grep -o '[0-9]*')
  SKIPPED=$(grep -o 'skipped="[0-9]*"' test-results.xml | head -1 | grep -o '[0-9]*' || echo "0")
  PASSED=$((TOTAL - FAILURES - SKIPPED))
  RETRIES=$(find test-results -name "*retry*" -type d 2>/dev/null | wc -l | tr -d ' ')
  
  echo "| Status | Count | Percentage |" >> $GITHUB_STEP_SUMMARY
  echo "|--------|-------|------------|" >> $GITHUB_STEP_SUMMARY
  
  if [ $TOTAL -gt 0 ]; then
    PASS_PCT=$((PASSED * 100 / TOTAL))
    FAIL_PCT=$((FAILURES * 100 / TOTAL))
    SKIP_PCT=$((SKIPPED * 100 / TOTAL))
    
    echo "| ✅ Passed | $PASSED | ${PASS_PCT}% |" >> $GITHUB_STEP_SUMMARY
    echo "| ❌ Failed | $FAILURES | ${FAIL_PCT}% |" >> $GITHUB_STEP_SUMMARY
    echo "| 🔁 Retried | $RETRIES | - |" >> $GITHUB_STEP_SUMMARY
    echo "| ⏭️ Skipped | $SKIPPED | ${SKIP_PCT}% |" >> $GITHUB_STEP_SUMMARY
    echo "| 📊 **Total** | **$TOTAL** | **100%** |" >> $GITHUB_STEP_SUMMARY
  
  # Individual test results - Only show failed and retried tests
  echo "" >> $GITHUB_STEP_SUMMARY
  
  # Count failed and retried tests
  FAILED_COUNT=$(grep '<testcase' test-results.xml | grep -v '/>' | wc -l | tr -d ' ')
  RETRIED_COUNT=$(find test-results -name "*retry*" -type d 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$FAILED_COUNT" -gt 0 ] || [ "$RETRIED_COUNT" -gt 0 ]; then
    echo "### ⚠️ Failed & Retried Tests" >> $GITHUB_STEP_SUMMARY
    echo "" >> $GITHUB_STEP_SUMMARY
    echo "| Status | Directory Name | Test Name |" >> $GITHUB_STEP_SUMMARY
    echo "|--------|----------------|-----------|" >> $GITHUB_STEP_SUMMARY
    
    # Parse individual test cases from JUnit XML using grep and sed
    grep '<testcase' test-results.xml | while IFS= read -r line; do
      # Extract classname and name
      CLASSNAME=$(echo "$line" | sed -n 's/.*classname="\([^"]*\)".*/\1/p')
      TESTNAME=$(echo "$line" | sed -n 's/.*name="\([^"]*\)".*/\1/p')
      
      # Extract directory name from classname (e.g., "login" from "specs/login/admin-login.spec.ts")
      SPEC_DIR=$(echo "$CLASSNAME" | sed 's|specs/\([^/]*\)/.*|\1|')
      
      # Extract spec file name without path and extension
      SPEC_FILE=$(echo "$CLASSNAME" | sed 's|.*/||' | sed 's|\.spec\.ts||')
      
      # Combine spec file and test name
      FULL_TEST_NAME="$SPEC_FILE › $TESTNAME"
      
      # Check if it's a self-closing tag (passed) or has failure
      if echo "$line" | grep -q '/>$'; then
        # Self-closing means passed - skip it
        continue
      else
        # Need to check following lines for failure
        NEXT_LINE=$(grep -A 1 "name=\"$TESTNAME\"" test-results.xml | tail -1)
        if echo "$NEXT_LINE" | grep -q '<failure\|<error'; then
          echo "| ❌ | $SPEC_DIR | $FULL_TEST_NAME |" >> $GITHUB_STEP_SUMMARY
        fi
      fi
    done
    
    # Add retried tests if any
    if [ "$RETRIED_COUNT" -gt 0 ]; then
      echo "" >> $GITHUB_STEP_SUMMARY
      echo "_Note: $RETRIED_COUNT test(s) were retried_" >> $GITHUB_STEP_SUMMARY
    fi
  else
    echo "### ✅ All Tests Passed" >> $GITHUB_STEP_SUMMARY
    echo "" >> $GITHUB_STEP_SUMMARY
    echo "_No failed or retried tests to display._" >> $GITHUB_STEP_SUMMARY
  fi
  fi
else
  echo "⚠️ No test results found" >> $GITHUB_STEP_SUMMARY
fi
