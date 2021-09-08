#!/bin/sh

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/git-util.sh

TAG_NAME=$(get_latest_tag)
RELEASE_BRANCH_NAME="$TAG_NAME-release-branch"

echo "Proposing to create release branch from tag:"
echo "  name = $RELEASE_BRANCH_NAME"
echo "  from = $TAG_NAME"
echo "Create branch? Press ENTER to continue. Ctrl+C to cancel."
read

git checkout -b "$RELEASE_BRANCH_NAME" "$TAG_NAME"

echo "Push branch? Press ENTER to continue. Ctrl+C to cancel."
read

git push origin "$RELEASE_BRANCH_NAME"

title="Release branch *$RELEASE_BRANCH_NAME* created"
subtitle="<https://github.com/neevaco/neeva-ios-phoenix/tree/$RELEASE_BRANCH_NAME|Github branch>"
Scripts/send-slack-message.sh "$title" "$subtitle"
