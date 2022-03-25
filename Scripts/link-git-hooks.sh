#!/bin/bash

root="$(pwd)"

# find all hooks and link them
for f in $(ls -1Ap $root/.githooks/ | grep -v '/$')
do
    ln -sf "$root/.githooks/$f" "$root/.git/hooks/$f"
    chmod +x "$root/.git/hooks/$f"
done