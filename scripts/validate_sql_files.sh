#!/bin/bash

# Check JSON  exists for all rules

SQL_FILES_DIRECTORY=$1
DATABASE_NAME=$2

usage() {
    echo "Usage: $0 <sql root directory> <database_name>"
    exit 1
}

error() {
    echo "ERROR: $1"
}

check_parameters() {
    if [[ -z $SQL_FILES_DIRECTORY ]];
    then
        error "SQL directory must be specified"
        usage
    fi

    if [[ -z $DATABASE_NAME ]];
    then
        error "Database name must be specified"
        usage
    fi
}

init_database() {
    SQL_STATEMENT="CREATE TABLE IF NOT EXISTS my_table (my_column text);"
    psql --dbname=${DATABASE_NAME} -c "${SQL_STATEMENT}" > /dev/null
    if [[ $? -gt 0 ]]; then
        error "Failed to create ${DATABASE_NAME} test table"
        exit 2
    fi
}

test_sql_file() {
    echo "Validate ${FILE}"
    TEMPORARY_FILE=$(mktemp /tmp/sql.XXXXXXXXXX)
    cat ${FILE} \
        | sed -e "s/<replace_with_column>/my_column/" \
        | sed -e "s/<replace_with_table>/my_table/" \
        | sed -e "s/<replace_with_pid>/42/" \
        | sed -e "s/<user_to_limit>/postgres/" \
        | sed -e "s/<max_connection_limit_for_role>/42/" \
        > ${TEMPORARY_FILE}
    psql --dbname=${DATABASE_NAME} -f ${TEMPORARY_FILE} > /dev/null
    if [[ $? -gt 0 ]]; then
        error "Failed to process ${FILE}"
        exit 3
    fi
}

check_sql_files() {
    FILES=$(find ${SQL_FILES_DIRECTORY} -name \*.sql)
    for FILE in ${FILES};
    do
        test_sql_file $FILE
    done
}

check_parameters

init_database

check_sql_files
