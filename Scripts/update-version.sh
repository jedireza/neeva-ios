#!/bin/sh

# This script helps with updating the build number and marketing version
# number. It reads the current values and proposes new values. Normally,
# the right thing to do is to just accept what this script produces.

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/git-util.sh
. $SCRIPTS_DIR/version-util.sh

# We expect to be run from the root directory of the project.
if [ ! -s $PROJECT_FILE ]; then
    echo "Error: $PROJECT_FILE not found"
    exit 1
fi

# Search and replace on $PROJECT_FILE the field named $1 with new value $2.
put_version() {
    if [ $# != 2 ]; then
        echo "put_version: expected two arguments"
        exit 1
    fi
    field_name=$1
    new_value=$2
    perl -pi -e "s/$field_name = .*;/$field_name = $new_value;/g" $PROJECT_FILE
}

# Increment the given input value by one.
increment_number() {
    if [ $# != 1 ]; then
        echo "increment_number: expected one argument"
        exit 1
    fi
    number=$1
    expr "$1" + 1
}

# For version numbers of the form (major).(minor).(patch), increment the patch
# number and return the resulting version string.
increment_version_patch() {
    if [ $# != 1 ]; then
        echo "increment_version_patch: expected one argument"
        exit 1
    fi
    version=$1
    major=$(echo "$version" | cut -d'.' -f1)
    minor=$(echo "$version" | cut -d'.' -f2)
    patch=$(echo "$version" | cut -d'.' -f3)
    echo "$major.$minor.$(increment_number $patch)"
}

# On "main", build numbers are just single integers, but on release branches
# they are of the form (first).(second), where (second) is incremented with
# each build.
increment_build_number() {
    if [ $# != 1 ]; then
        echo "increment_build_number: expected one argument"
        exit 1
    fi
    build_number=$1
    if is_branch_of_main; then
        increment_number $build_number
    else
        if [ $(echo "$build_number" | fgrep -c '.') = 0 ]; then
            echo "$build_number.1"
        else
            first=$(echo "$build_number" | cut -d'.' -f1)
            second=$(echo "$build_number" | cut -d'.' -f2)
            echo "$first.$(increment_number $second)"
        fi
    fi
}

MARKETING_VERSION=$(get_marketing_version)
CURRENT_PROJECT_VERSION=$(get_current_project_version)

echo "Current version info:"
echo "  MARKETING_VERSION = $MARKETING_VERSION"
echo "  CURRENT_PROJECT_VERSION = $CURRENT_PROJECT_VERSION"

PROPOSED_MARKETING_VERSION=$(increment_version_patch $MARKETING_VERSION)
PROPOSED_CURRENT_PROJECT_VERSION=$(increment_build_number $CURRENT_PROJECT_VERSION)

echo "Proposed version info:"

read -ep "  MARKETING_VERSION = [$PROPOSED_MARKETING_VERSION] " version
if [ -n "$version" ]; then
    PROPOSED_MARKETING_VERSION=$version
fi
read -ep "  CURRENT_PROJECT_VERSION = [$PROPOSED_CURRENT_PROJECT_VERSION] " version
if [ -n "$version" ]; then
    PROPOSED_CURRENT_PROJECT_VERSION=$version
fi

echo "New version info:"
echo "  MARKETING_VERSION = $PROPOSED_MARKETING_VERSION"
echo "  CURRENT_PROJECT_VERSION = $PROPOSED_CURRENT_PROJECT_VERSION"

echo "Commit version info? Press ENTER to continue. Ctrl+C to cancel."
read

put_version "MARKETING_VERSION" $PROPOSED_MARKETING_VERSION
put_version "CURRENT_PROJECT_VERSION" $PROPOSED_CURRENT_PROJECT_VERSION
