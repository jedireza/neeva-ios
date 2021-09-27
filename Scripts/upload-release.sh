#!/bin/sh

if [ -z $1 ]; then
  echo "Please specify the xcarchive filename. Abort"
  exit 1
fi

if [ -z ${APP_STORE_USERNAME} ] || [ -z ${APP_STORE_TOKEN} ]; then
  echo "APP_STORE_USERNAME or APP_STORE_TOKEN not defined. Abort"
  exit 1
fi

APP_VERSION=$(/usr/libexec/PlistBuddy -c 'print ":ApplicationProperties:CFBundleShortVersionString"' $1/Info.plist)

# convert xcarchive to ipa
xcodebuild -exportArchive -archivePath $1 -exportPath /tmp -exportOptionsPlist Scripts/ExportOptions.plist

echo "Uploading build $APP_VERSION to Testflight? Press ENTER to continue. Ctrl+C to cancel."
read

xcrun altool --upload-app -f /tmp/Client.ipa --type ios --username $APP_STORE_USER --password $APP_STORE_TOKEN
