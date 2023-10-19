#!/bin/bash

# Generate website into public folder for each Git tag

set -e

BASE_URL=$1

usage() {
    echo "Usage: $0 <base_URL>"
    exit 1
}

error() {
    echo "ERROR: $1"
}

check_parameters() {
    if [[ -z $BASE_URL ]];
    then
        error "Base URL must be specified"
        usage
    fi
}

init() {
    INITIAL_GIT_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    TAGS=$(git tag -l --sort=refname)
    LATEST_VERSION=$(git tag --sort=-v:refname | head -n 1)

    TARGET_FOLDER=public
    INDEX_TEMPLATE="$(dirname $0)/templates/index.html"
    INDEX_FILE="${TARGET_FOLDER}/index.html"

    echo "- Copy template"
    cp -v ${INDEX_TEMPLATE} ${INDEX_FILE}
}

generate_website() {
    RELEASE_NAME=$1
    RELEASE_FOLDER="${TARGET_FOLDER}/${RELEASE_NAME}"

    BUILD_DATA_FILE=data/build.yaml

    echo "=> Update release data"
    yq -i ".current = \"${RELEASE_NAME}\"" ${BUILD_DATA_FILE}
    yq -i ".latest = \"${LATEST_VERSION}\"" ${BUILD_DATA_FILE}

    echo "=> Generate website for ${RELEASE_NAME} in ${RELEASE_FOLDER}"
    hugo --gc --minify --baseURL "${BASE_URL}/${RELEASE_NAME}/" --destination ${RELEASE_FOLDER}

    echo "=> Add release to index"
    MARKER="<!-- release_link -->"
    LINE="        <li><a href='${RELEASE_NAME}'>${RELEASE_NAME}</a></li>"
    sed -i "s@$MARKER@$MARKER\n$LINE@" ${INDEX_FILE}
}

generate_websites() {
    for TAG in $TAGS;
    do
        echo "Process ${TAG}"

        echo "=> Checkout ${TAG}"
        git checkout ${TAG}

        generate_website ${TAG}

        reset_git_repository

    done

    echo "Generate latest release"
    generate_website "latest"

    reset_git_repository
}

reset_git_repository() {
    git reset --hard  > /dev/null
    git checkout ${INITIAL_GIT_BRANCH_NAME}
}

check_parameters
init
generate_websites
