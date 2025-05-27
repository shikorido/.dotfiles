# DOTFILES management
# master
# reset_utils.sh

get_worktree_for_branch() {
    git worktree list --porcelain |
    awk -v b="refs/heads/$1" '
        $1 == "worktree" { $1 = ""; sub(/^ /, ""); wt = $0; }
        $1 == "branch" && $2 == b { print wt; }
    '
    return 0
}

reset_branch() (
    branch="$1"
    if  git show-ref --verify --quiet "refs/heads/$branch" &&
        git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        # Compare the refs to skip redundant "git update-ref" invocation
        if ! [ "`git rev-parse "refs/heads/$branch"`" = "`git rev-parse "refs/remotes/origin/$branch"`" ]; then
            echo "Updating refs/heads/$branch to point on refs/remotes/origin/$branch"
            git update-ref "refs/heads/$branch" "refs/remotes/origin/$branch"
        fi

        worktree=`get_worktree_for_branch "$branch"`
        if [ -n "$worktree" ]; then
            if [ -n "`git -C "$worktree" status --porcelain`" ]; then
                echo "Resetting $branch in $worktree to origin/$branch"
                git -C "$worktree" reset --hard "origin/$branch"
                git -C "$worktree" clean -df
            else
                echo "Reset skip: Worktree is clean for refs/heads/$branch and up-to-date with refs/remotes/origin/$branch"
            fi
        else
            echo "Nothing to reset: Could not find worktree for refs/heads/$branch"
        fi
    fi
    exit 0
)





# Etc.

# Check if the branch is currently checked out in a worktree
#if git worktree list | grep -q "[$branch]"; then
#    echo "Skipping $branch: checked out in a worktree."
#else
#    echo "Resetting $branch to origin/$branch"
#    git update-ref "refs/heads/$branch" "refs/remotes/origin/$branch"
#fi

#git worktree list --porcelain | awk '
#/^worktree / { wt=$2; }
#/^branch / { br=$2; sub("refs/heads/", "", br); print wt, br }
#' | while read wt br; do
#   echo "Resetting $br in $wt to origin/$br"
#   git -C "$wt" fetch origin "$br"
#   git -C "$wt" reset --hard "origin/$br"
#done

