#!/bin/sh

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/version-util.sh

MARKETING_VERSION=$(get_marketing_version)
CURRENT_PROJECT_VERSION=$(get_current_project_version)

title="Uploaded Build #*$CURRENT_PROJECT_VERSION* (*v$MARKETING_VERSION*) to App Store"
subtitle="<https://appstoreconnect.apple.com/apps/1543288638/testflight/ios/|App Store TestFlight>"

echo "Build uploaded to App Store? Press ENTER to continue. Ctrl+C to cancel."
read

Scripts/send-slack-message.sh "$title" "$subtitle"
