#!/bin/sh

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/git-util.sh
. $SCRIPTS_DIR/version-util.sh

MARKETING_VERSION=$(get_marketing_version)
CURRENT_PROJECT_VERSION=$(get_current_project_version)
COMMIT=$(get_latest_commit)

TAG_NAME="Build-$CURRENT_PROJECT_VERSION"
TAG_DESCRIPTION="v$MARKETING_VERSION"

echo "Proposing to create tag:"
echo "  name = $TAG_NAME"
echo "  message = $TAG_DESCRIPTION"
echo "  commit = $COMMIT"
echo "Create tag? Press ENTER to continue. Ctrl+C to cancel."
read

git tag -a "$TAG_NAME" -m "$TAG_DESCRIPTION" $COMMIT
