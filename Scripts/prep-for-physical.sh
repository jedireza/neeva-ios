#!/bin/sh

# This script prepares a contributor's (i.e., non-Neeva employee's) environment to build directly to a physical device.
# Make sure to run this in the root directory of your repo, e.g. sh Scripts/prep-for-physical.sh
# Having a problem with the script? File an issue in our GitHub repo.

NEEVA_TEAM_ID=A9735M6NPH
NEEVA_BUNDLE_ID=co.neeva

read -p "What is your team ID? " team_id
sed -i '' "s/$NEEVA_TEAM_ID/$team_id/g" Client.xcodeproj/project.pbxproj

read -p "What is your bundle ID (e.g., com.lastname)?  " bundle_id
git grep -l $NEEVA_BUNDLE_ID -- 'Client.xcodeproj/project.pbxproj' '*Dev.entitlements' 'Shared/API/Network.swift' | xargs sed -i '' "s/$NEEVA_BUNDLE_ID/$bundle_id/g"

# Delete Siri and Web Browser entitlements
sed -i '' '/com.apple.developer.siri/,+3d' Client/Entitlements/NeevaDev.entitlements
