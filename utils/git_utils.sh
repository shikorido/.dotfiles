# DOTFILES management
# master
# git_utils.sh

[ "$_GIT_UTILS_H" = 1 ] && return 0
_GIT_UTILS_H=1
. "${master_root:-.}/utils/logger.sh"

is_valid_gitrev() {
    git rev-parse --verify --quiet "$1" >/dev/null; return
}

is_valid_gitbranch() {
    git show-ref --verify --quiet "refs/heads/$1"; return
}

get_worktree() (
    wt=`git worktree list --porcelain |
        awk -v b="refs/heads/$1" '
            $1 == "worktree" { $1 = ""; sub(/^ /, ""); wt = $0; }
            $1 == "branch" && $2 == b { print wt; }
        '`
    test "$wt" && printf "%s\n" "$wt"
    test "$wt"; exit
)

prepare_worktree() (
    __FUNC__=prepare_worktree
    [ $# -eq 0 ] || [ $# -gt 2 ] && exit 1
    if [ $# -eq 1 ]; then
        [ "$1" = "${1#*/}" ] || exit
        desired_path=$1
        branch=$1
    fi
    if [ $# -eq 2 ]; then
        [ "$2" = "${2#*/}" ] || exit
        desired_path=$1
        branch=$2
    fi
    is_valid_gitbranch "$branch" || exit
    wt=`get_worktree "$branch"`
    if [ -z "$wt" ]; then
        git worktree add "$desired_path" "$branch"
    elif ! [ "$wt" = "$script_dir/$branch" ]; then
        log WARN "$__FUNC__" "WARNING: %s is checked out at %s\n" "$branch" "$wt"
        log WARN "$__FUNC__" "It will be transfered to %s/%s\n" "$script_dir" "$branch"
        log WARN "$__FUNC__" "to comply with scripts expectations"
        git worktree move -f -f "$wt" "$script_dir/$branch"
    else true; fi
    exit
)

reset_branch() (
    __FUNC__=reset_branch
    branch="$1"
    if  git show-ref --verify --quiet "refs/heads/$branch" &&
        git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        # Compare the refs to skip redundant "git update-ref" invocation
        if ! [ "`git rev-parse "refs/heads/$branch"`" = "`git rev-parse "refs/remotes/origin/$branch"`" ]; then
            log INFO "$__FUNC__" "Updating refs/heads/%s to point on refs/remotes/origin/%s\n" "$branch" "$branch"
            git update-ref "refs/heads/$branch" "refs/remotes/origin/$branch"
        fi

        worktree=`get_worktree "$branch"`
        if [ -n "$worktree" ]; then
            if [ -n "`git -C "$worktree" status --porcelain`" ]; then
                log WARN "$__FUNC__" "Resetting %s in %s to origin/%s\n" "$branch" "$worktree" "$branch"
                git -C "$worktree" reset --hard "origin/$branch"
                git -C "$worktree" clean -df
            else
                log INFO "$__FUNC__" "Reset skip: Worktree is clean for refs/heads/%s and up-to-date with refs/remotes/origin/%s\n" "$branch" "$branch"
            fi
        else
            log INFO "$__FUNC__" "Nothing to reset. Unable to find worktree for refs/heads/%s\n" "$branch"
        fi
    fi
    exit 0
)
