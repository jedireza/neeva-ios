# This script is meant to be source included.

# Gets the hash of the latest commit.
get_latest_commit() {
    git log -1 --oneline | cut -d' ' -f1
}

# Gets the name of the latest tag.
get_latest_tag() {
    git tag --list 'Build-*' | sort -V | tail -n 1
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

# Check if current branch is a release branch.
is_branch_of_release() {
    [[ $(get_remote_branch) =~ origin/Build-* ]]
}

# Check if there are uncommitted files.
has_uncommitted_files() {
    test -n "$(git status -s | grep -v '^?? ')"
}

# Prompt user to review pending changes and retries 3 times before exiting
retry_script_prompt_with_uncommitted_files() {
    i=0
    while true
    do
        # retry 3 times before giving up
        if has_uncommitted_files; then
        if [ $i -eq 3 ]; then
            echo "Retried 3 times. You still have uncommitted files. Please commit or stash, and then re-run prepare next version script."
            exit 1
        else
            echo "****************************************"
            git status
            echo "****************************************"
            echo "You have uncommitted files. Please review changes, commit or stash, Press ENTER to retry. Ctrl+C to cancel."
            read
        fi
    else
        break
    fi
    ((i=i+1))
    done
}
