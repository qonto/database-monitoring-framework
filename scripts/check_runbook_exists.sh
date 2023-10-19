#!/bin/bash

# Check a runbook exists for all rules

CHART_DIRECTORY=$1
RUNBOOK_DIRECTORY=$2

usage() {
    echo "Usage: $0 <chart> <runbook>"
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

    if [[ -z $RUNBOOK_DIRECTORY || ! -d "$RUNBOOK_DIRECTORY" ]];
    then
        error "Runbook directory must be specified"
        usage
    fi
}

check_files() {
    ALERTS=$(yq -o tsv --exit-status -r '.rules | keys' ${CHART_DIRECTORY}/values.yaml)
    for ALERT in $ALERTS;
    do
        echo "Check $ALERT alert";
        EXPECTED_RUNBOOK_FILE="${RUNBOOK_DIRECTORY}/${ALERT}.md"
        if [ ! -f $EXPECTED_RUNBOOK_FILE ]; then
            error "No runbook found for ${ALERT} alert, you must define a runbook in ${EXPECTED_RUNBOOK_FILE}"
            echo "       Execute 'make new-runbook > ${EXPECTED_RUNBOOK_FILE}' to create it"
            exit 2
        fi
    done
}

check_parameters

check_files
