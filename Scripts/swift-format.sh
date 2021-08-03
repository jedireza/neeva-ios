#!/bin/sh

HELP="--help"
FORMAT_ALL="--format-all"
CHECK="--check"
CHECK_ALL="--check-all"

args=(--configuration .swiftformat.json)
if [ "$1" = "$HELP" ]; then
    echo "USAGE:"
    echo "  ./Scripts/swift-format.sh               # format changed files"
    echo "  ./Scripts/swift-format.sh $CHECK       # check changed files"
    echo "  ./Scripts/swift-format.sh $FORMAT_ALL  # format all files"
    echo "  ./Scripts/swift-format.sh $CHECK_ALL   # check all files"
    exit 0
elif [ "$1" = "$FORMAT_ALL" -o "$1" = "$CHECK_ALL" ]; then
    args+=(--recursive)
    files=($(cat $(dirname $0)/swift-format-dirs.txt))
else
    files=($($(dirname $0)/files-to-format.sh))
fi

if [ -z "$files" ]; then
    echo "No files to format"
else
    if [ "$1" != "$CHECK_ALL" -a "$1" != "$CHECK" ]; then
        ./swift-format/.build/release/swift-format format --in-place "${args[@]}" "${files[@]}"
        status=$?
        if [ "$status" != 0 ]; then
            exit $status
        fi
    fi
    ./swift-format/.build/release/swift-format lint "${args[@]}" "${files[@]}"
    exit $?
fi
