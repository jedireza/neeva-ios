#!/bin/bash
# See .circleci/config.yml#commands.ui-tests

if [ "$1" = "move-iphone-screenshots" ]; then
    if [ -d ui-test-screenshots ]; then
        mv ui-test-screenshots ui-test-screenshots-$CIRCLE_BUILD_NUM
    fi
    exit 0
elif [ "$1" != "store-artifacts" ]; then
    echo "Invalid command '$1'"
    exit 1
fi

function check-zip {
    if [ $1 = 12 ]; then
        echo "Failing silently."
    elif [ $1 != 0 ]; then
        exit $1
    fi
}

mkdir artifacts

# iPhone screenshots
if [ -d ui-test-screenshots ]; then
    mv ui-test-screenshots ui-test-screenshots-ipad-$CIRCLE_BUILD_NUM
    zip -r artifacts/ui-test-screenshots-ipad-$CIRCLE_BUILD_NUM.zip ui-test-screenshots-ipad-$CIRCLE_BUILD_NUM
    check-zip $?
fi

# iPad screenshots
if [ -d ui-test-screenshots-$CIRCLE_BUILD_NUM ]; then
    zip -r artifacts/ui-test-screenshots-$CIRCLE_BUILD_NUM.zip ui-test-screenshots-$CIRCLE_BUILD_NUM
    check-zip $?
fi

# iPhone xcresult
zip -r artifacts/uitests-$CIRCLE_BUILD_NUM.xcresult.zip uitests-$CIRCLE_BUILD_NUM.xcresult
check-zip $?

# iPad xcresult
zip -r artifacts/uitests-ipad-$CIRCLE_BUILD_NUM.xcresult.zip uitests-ipad-$CIRCLE_BUILD_NUM.xcresult
check-zip $?
