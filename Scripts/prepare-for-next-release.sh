#!/bin/sh

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/git-util.sh
. $SCRIPTS_DIR/version-util.sh

echo "Make sure Xcode does not have the project open."
echo "Press ENTER to continue. Ctrl+C to cancel."
read

# 1- Make sure the tree is clean
if has_uncommitted_files; then
    echo "You have uncommitted files. Please commit or stash, and then re-run."
    exit 1
fi

# 2- Run update-version.sh
$SCRIPTS_DIR/update-version.sh

# 3- Get version and create branch accordingly
CURRENT_PROJECT_VERSION=$(get_current_project_version)

BRANCH_NAME="$(git_user_name)/prepare-for-build-$CURRENT_PROJECT_VERSION"
REMOTE_NAME="$(get_remote_branch)"

echo "Proposing to create branch:"
echo "  name = $BRANCH_NAME"
echo "  from = $REMOTE_NAME"
echo "Create branch? Press ENTER to continue. Ctrl+C to cancel."
read

git checkout -b $BRANCH_NAME $REMOTE_NAME
git diff
git commit -a -m "Preparing for build $CURRENT_PROJECT_VERSION"

# 4- Upload branch for review

echo "Push branch? Press ENTER to continue. Ctrl+C to cancel."
read

git push origin $BRANCH_NAME
