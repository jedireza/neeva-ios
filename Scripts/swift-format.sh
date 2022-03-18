#!/bin/sh

HELP="--help"
FORMAT_ALL="--format-all"
CHECK="--check"
CHECK_ALL="--check-all"
STRICT="--strict"

args=(--configuration .swiftformat.json)

for arg in "$@"; do
    if [ "$arg" = "$HELP" ]; then
        echo "USAGE:"
        echo "  ./Scripts/swift-format.sh               # format changed files"
        echo "  ./Scripts/swift-format.sh $CHECK       # check changed files"
        echo "  ./Scripts/swift-format.sh $FORMAT_ALL  # format all files"
        echo "  ./Scripts/swift-format.sh $CHECK_ALL   # check all files"
        echo "  use $STRICT with $CHECK or $CHECK_ALL to enable strict mode"
        exit 0
    elif [ "$arg" = "$FORMAT_ALL" -o "$arg" = "$CHECK_ALL" ]; then
        args+=(--recursive)
        files=($(cat $(dirname $0)/swift-format-dirs.txt))
    elif [ "$arg" = "$CHECK" ]; then
        files=($($(dirname $0)/files-to-format.sh))
    elif [ "$arg" = "$STRICT" ]; then
        args+=(--strict)
    fi
done

# support for shorthand /Scripts/swift-format.sh
if [ $# -eq 0 ]; then
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
