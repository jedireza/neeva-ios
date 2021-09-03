#!/bin/sh

# Script used to build a release. Use the Xcode Organizer to distribute
# the resulting archive.

./bootstrap.sh

xcodebuild clean archive -scheme Client -workspace Neeva.xcworkspace -configuration Release

# Open Xcode Organizer
osascript Scripts/open-organizer.as > /dev/null

# Confirm uploading build to app store
Scripts/confirm-upload-binary.sh

# Generate tag for build
Scripts/tag-release.sh
