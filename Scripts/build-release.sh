#!/bin/sh

UPLOAD_BUILD=false
while getopts ":u" option; do
  case $option in
    u) # upload
       UPLOAD_BUILD=true
  esac
done

# Script used to build a release. Use the Xcode Organizer to distribute
# the resulting archive.

./bootstrap.sh

if $UPLOAD_BUILD; then
  ARCHIVE_PATH=~/Library/Developer/Xcode/Archives
  NEEVA_ARCHIVE_PATH=$ARCHIVE_PATH/Neeva

  # Create Neeva Archive directory to store archive for upload
  # Note that Xcode looks at all the Archive files in Archives
  # directory so we have record in Xcode Organizer
  mkdir -p $ARCHIVE_PATH
  mkdir -p $NEEVA_ARCHIVE_PATH
  if [ ! -d $NEEVA_ARCHIVE_PATH ]; then
    echo "Failed to create directory $NEEVA_ARCHIVE_PATH"
    exit 1
  fi

  ARCHIVE_FILENAME=Client_$(date '+%Y-%m-%d_%H_%M').xcarchive
  xcodebuild clean archive -scheme Client -workspace Neeva.xcworkspace -configuration Release -archivePath $NEEVA_ARCHIVE_PATH/$ARCHIVE_FILENAME
  if [ ! $? -eq 0 ]; then
    echo "Build failed. Abort"
    exit 1
  fi

  Scripts/upload-release.sh $NEEVA_ARCHIVE_PATH/$ARCHIVE_FILENAME
  if [ ! $? -eq 0 ]; then
    exit 1
  fi
else
  xcodebuild clean archive -scheme Client -workspace Neeva.xcworkspace -configuration Release

  # Open Xcode Organizer
  osascript Scripts/open-organizer.as > /dev/null
fi


# Confirm uploading build to app store
Scripts/confirm-upload-binary.sh

# Generate tag for build
Scripts/tag-release.sh
