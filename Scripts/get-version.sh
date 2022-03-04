#!/bin/sh

SCRIPTS_DIR=$(dirname $0)

. $SCRIPTS_DIR/version-util.sh

echo "Current version info:"
echo "  MARKETING_VERSION = $(get_marketing_version)"
echo "  CURRENT_PROJECT_VERSION = $(get_current_project_version)"
