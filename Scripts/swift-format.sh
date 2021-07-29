#!/bin/sh

if [ "$1" = "--help" ]; then
    echo "USAGE:"
    echo "  ./Scripts/swift-format.sh          # format changed files"
    echo "  ./Scripts/swift-format.sh --all    # format all files"
    exit 0
elif [ "$1" = "--all" ]; then
    files=(--recursive)
    files+=($(cat $(dirname $0)/swift-format-dirs.txt))
else
    files=($($(dirname $0)/files-to-format.sh))
fi

if [ -z "$files" ]; then
    echo "No files to format"
elif [ -z $CI ] && [ -z "$CONFIGURATION" -o "$CONFIGURATION" = "Debug" ]; then
    ./swift-format/.build/release/swift-format format --configuration .swiftformat.json --in-place "${files[@]}"
fi
