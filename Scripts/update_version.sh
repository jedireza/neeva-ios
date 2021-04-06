#!/bin/sh

FILE="Client.xcodeproj/project.pbxproj"

# We expect to be run from the root directory of the project.
if [ ! -s $FILE ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Extract version field specified by $1 from $FILE. Expect version field to be
# of the form: (whitespace)$1 = (version);(whitespace)
get_version() {
    if [ $# != 1 ]; then
        echo "get_version: expected one argument"
        exit 1
    fi
    field_name=$1
    fgrep "$field_name = " $FILE | uniq | cut -d' ' -f3 | cut -d';' -f1
}

# Search and replace on $FILE the field named $1 with new value $2.
put_version() {
    if [ $# != 2 ]; then
        echo "put_version: expected two arguments"
        exit 1
    fi
    field_name=$1
    new_value=$2
    perl -pi -e "s/$field_name = .*;/$field_name = $new_value;/g" $FILE
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

MARKETING_VERSION=$(get_version "MARKETING_VERSION")
CURRENT_PROJECT_VERSION=$(get_version "CURRENT_PROJECT_VERSION")

echo "Current version info:"
echo "  MARKETING_VERSION = $MARKETING_VERSION"
echo "  CURRENT_PROJECT_VERSION = $CURRENT_PROJECT_VERSION"

PROPOSED_MARKETING_VERSION=$(increment_version_patch $MARKETING_VERSION)
PROPOSED_CURRENT_PROJECT_VERSION=$(increment_number $CURRENT_PROJECT_VERSION)

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
