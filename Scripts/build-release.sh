#!/bin/sh

# Script used to build a release. Use the Xcode Organizer to distribute
# the resulting archive.

./bootstrap.sh

xcodebuild clean archive -scheme Client -workspace Neeva.xcworkspace -configuration Release
