# This script is meant to be source included.

# Gets the hash of the latest commit.
get_latest_commit() {
    git log -1 --oneline | cut -d' ' -f1
}

git_user_name() {
    git config user.email | cut -d'@' -f1
}

get_remote_branch() {
    branched_from=$(git status -b -s -uno | grep '^##' | cut -d' ' -f2 | sed -E 's/.*origin\/(.*)/\1/')
    echo "origin/$branched_from"
}

# Check if current branch is a branch from "main".
is_branch_of_main() {
    test "$(get_remote_branch)" = "origin/main"
}

# Check if there are uncommitted files.
has_uncommitted_files() {
    test -n "$(git status -s | grep -v '^?? ')"
}
