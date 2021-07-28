#!/bin/sh

files=(./Client ./ClientTests ./Extensions ./Providers ./Shared ./SharedTests ./SiriShortcuts ./Storage ./StoragePerfTests ./StorageTests ./AppClip ./WidgetKit ./UITests ./XCUITests ./Codegen)

 if [ -z $CI ] && [ -z "$CONFIGURATION" -o "$CONFIGURATION" = "Debug" ]; then
     ./swift-format/.build/release/swift-format format --recursive --configuration .swiftformat.json --in-place "${files[@]}"
 fi
