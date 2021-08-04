#!/bin/bash

# fetch diff between the current commit and origin/main, only including non-deleted files
git diff --no-renames --name-status origin/main -- $(cat $(dirname $0)/swift-format-dirs.txt) | awk '!match($1, "D"){print $2}' | grep .swift
