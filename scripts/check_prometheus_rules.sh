#!/bin/sh

# Check Prometheus rules in chart are valid

set -eo pipefail

CHART_DIRECTORY=$1
PROMETHEUS_TEST_DIRECTORY="${CHART_DIRECTORY}/prometheus_tests"

usage() {
    echo "Usage: $0 <chart directory>"
    exit 1
}

error() {
    echo "ERROR: $1"
}

check_parameters() {
    if [[ -z $CHART_DIRECTORY || ! -d $CHART_DIRECTORY ]];
    then
        error "Chart directory must be specified"
        usage
    fi

    if [[ ! -d $PROMETHEUS_TEST_DIRECTORY ]];
    then
        error "Prometheus test directory (${PROMETHEUS_TEST_DIRECTORY}) must exist"
        usage
    fi
}

check_files() {
    # Render Helm chart
    TEMPORARY_DIRECTORY=$(mktemp -p /tmp -d)
    RULES_FILE=${TEMPORARY_DIRECTORY}/rules.yml
    helm template ${CHART_DIRECTORY} --set format=PrometheusConfigurationFile > ${RULES_FILE}

    # Copy test files in a temporary directory
    cp ${PROMETHEUS_TEST_DIRECTORY}/*.yml ${TEMPORARY_DIRECTORY}

    # Run Prometheus rule tests
    TEST_FILES=$(find ${TEMPORARY_DIRECTORY} -path '*.yml' ! -name rules.yml | tr "\n" " ")
    promtool test rules ${TEST_FILES}

    # Detect Prometheus rules without tests
    MISSING_TESTS=0
    PROMETHEUS_ALERTS=$(yq -r '.groups[0].rules[] | .alert' ${RULES_FILE})
    for PROMETHEUS_ALERT in ${PROMETHEUS_ALERTS};
    do
        PROMETHEUS_ALERT_TEST_FILE="${TEMPORARY_DIRECTORY}/${PROMETHEUS_ALERT}.yml"
        if [[ ! -f ${PROMETHEUS_ALERT_TEST_FILE} ]];
        then
            error "Missing test for ${PROMETHEUS_ALERT}"
            MISSING_TESTS=$((++MISSING_TESTS))
        fi
    done

    if [ ${MISSING_TESTS} -gt 0 ];
    then
        error "${MISSING_TESTS} missing test(s)"
        exit 1
    fi

    # Remove temporary folder
    rm -rf ${TEMPORARY_DIRECTORY}
}

check_parameters

check_files
