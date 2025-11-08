#!/bin/bash

# Script to run the flaky test multiple times to identify the issue
# This will run TestStorageProviderUploadDownload repeatedly and log results

TEST_NAME="TestStorageProviderUploadDownload"
NUM_RUNS=20
LOG_DIR="./test_logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SUMMARY_LOG="${LOG_DIR}/summary_${TIMESTAMP}.log"

# Create log directory
mkdir -p "${LOG_DIR}"

echo "Running ${TEST_NAME} ${NUM_RUNS} times..." | tee "${SUMMARY_LOG}"
echo "Started at: $(date)" | tee -a "${SUMMARY_LOG}"
echo "============================================" | tee -a "${SUMMARY_LOG}"
echo "" | tee -a "${SUMMARY_LOG}"

PASS_COUNT=0
FAIL_COUNT=0

for i in $(seq 1 ${NUM_RUNS}); do
    echo "Run #${i}/${NUM_RUNS}..." | tee -a "${SUMMARY_LOG}"

    RUN_LOG="${LOG_DIR}/run_${i}_${TIMESTAMP}.log"

    # Run the test and capture output
    cd testing
    go test -v -run "^${TEST_NAME}$" -timeout 60s > "${RUN_LOG}" 2>&1
    EXIT_CODE=$?
    cd ..

    if [ ${EXIT_CODE} -eq 0 ]; then
        echo "  ✓ PASS" | tee -a "${SUMMARY_LOG}"
        ((PASS_COUNT++))
    else
        echo "  ✗ FAIL (exit code: ${EXIT_CODE})" | tee -a "${SUMMARY_LOG}"
        ((FAIL_COUNT++))

        # Extract error information
        echo "  Error details:" | tee -a "${SUMMARY_LOG}"
        grep -A 5 "FAIL:" "${RUN_LOG}" | sed 's/^/    /' | tee -a "${SUMMARY_LOG}"
    fi

    # Brief pause between runs
    sleep 0.5
done

echo "" | tee -a "${SUMMARY_LOG}"
echo "============================================" | tee -a "${SUMMARY_LOG}"
echo "Test Summary:" | tee -a "${SUMMARY_LOG}"
echo "  Total runs: ${NUM_RUNS}" | tee -a "${SUMMARY_LOG}"
echo "  Passed: ${PASS_COUNT}" | tee -a "${SUMMARY_LOG}"
echo "  Failed: ${FAIL_COUNT}" | tee -a "${SUMMARY_LOG}"
echo "  Success rate: $(awk "BEGIN {printf \"%.1f\", (${PASS_COUNT}/${NUM_RUNS})*100}")%" | tee -a "${SUMMARY_LOG}"
echo "Completed at: $(date)" | tee -a "${SUMMARY_LOG}"
echo "" | tee -a "${SUMMARY_LOG}"

if [ ${FAIL_COUNT} -gt 0 ]; then
    echo "Failed test logs are available in: ${LOG_DIR}" | tee -a "${SUMMARY_LOG}"
    echo "" | tee -a "${SUMMARY_LOG}"
    echo "To view timing information from failed tests:" | tee -a "${SUMMARY_LOG}"
    echo "  grep 'time:' ${LOG_DIR}/run_*_${TIMESTAMP}.log | grep -v PASS" | tee -a "${SUMMARY_LOG}"
fi
