#!/bin/sh

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/git-util.sh
. $SCRIPTS_DIR/version-util.sh

MARKETING_VERSION=$(get_marketing_version)
CURRENT_PROJECT_VERSION=$(get_current_project_version)

RELEASE_BRANCH_NAME="Build-$CURRENT_PROJECT_VERSION-release-branch"

echo "Switching to main branch"
echo "Press ENTER to continue. Ctrl+C to cancel."
read

git checkout main

echo "Pulling latest branches and commit"
echo "Press ENTER to continue. Ctrl+C to cancel."
read

git fetch
git pull origin main

echo "Proposing to create branch:"
echo "  name = $RELEASE_BRANCH_NAME"
echo "Create branch? Press ENTER to continue. Ctrl+C to cancel."
read

git checkout -b "$RELEASE_BRANCH_NAME"

echo "Push branch? Press ENTER to continue. Ctrl+C to cancel."
read

git push origin "$RELASE_BRANCH_NAME"

title="Release branch *$RELEASE_BRANCH_NAME* created"
subtitle="<https://github.com/neevaco/neeva-ios-phoenix/tree/$RELEASE_BRANCH_NAME|Github branch>"
Scripts/send-slack-message.sh "$title" "$subtitle"

