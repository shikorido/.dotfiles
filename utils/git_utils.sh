# DOTFILES management
# master
# git_utils.sh

[ "$_GIT_UTILS_H" = 1 ] && return 0
_GIT_UTILS_H=1
. "${master_root:-.}/utils/logger.sh"

# With MSYS2, we must determine git's favor: cygwin or native.
# Even though it is strongly advised to use native git
# because plugins for nvim target it (handling cygwin git
# from native programs involves additional complexity
# such as native->msys arguments globbing and paths conversions).
# But since zsh is already running in msys layer, cygwin git will work fine.
_GIT_FLAVOR=posix

git_path_posix() {
    [ -z "$1" ] && return
    printf '%s\n' "`cygpath -a "$1"`"
}

git_path_windows() {
    [ -z "$1" ] && return
    printf '%s\n' "`cygpath -am "$1"`"
}

# Assume posix by default.
# This function will be redefined in case of windows git.
git_path_compatible() {
    git_path_posix "$1"
}

# Must be ran once in setup_variables when MSYS2 is detected.
determine_git_flavor() {
    ! [ "$MSYS2" ] && return
    case `git --exec-path` in
        /*);;
        ?:*)
            _GIT_FLAVOR=windows
            git_path_compatible() {
                git_path_windows "$1"
            };;
        *)
            log ERROR 'Unknown git flavor from `git --exec-path` output'
            exit 1
    esac
}

is_valid_gitrev() {
    git rev-parse --verify --quiet "$1" >/dev/null
}

is_valid_gitbranch() {
    git show-ref --verify --quiet "refs/heads/$1"
}

is_valid_gitremotebranch() {
    git show-ref --verify --quiet "refs/remotes/$1/$2"
}

get_worktree() (
    wt=`git worktree list --porcelain |
        awk -v b="refs/heads/$1" '
            $1 == "worktree" { $1 = ""; sub(/^ /, ""); wt = $0 }
            $1 == "branch" && $2 == b { print wt }
        '`
    [ "$wt" ] || exit
    wt=`git_path_posix "$wt"`
    printf '%s\n' "$wt"
)

prepare_worktree() (
    __FUNC__=prepare_worktree
    [ $# -eq 0 ] || [ $# -gt 2 ] && exit 1
    if [ $# -eq 1 ]; then
        [ "$1" = "${1#*/}" ] || exit
        branch=$1
    fi
    if [ $# -eq 2 ]; then
        [ "$2" = "${2#*/}" ] || exit
        branch=$2
    fi
    is_valid_gitbranch "$branch" || is_valid_gitremotebranch origin "$branch" || exit
    desired_path=`git_path_posix "$1"`
    wt=`get_worktree "$branch"`
    wt_new=`git_path_compatible "$desired_path"`
    if [ -z "$wt" ]; then
        git worktree add "$wt_new" "$branch"
    elif [ "$wt" != "$desired_path" ]; then
        log WARN "$__FUNC__" '%s is checked out at %s\n' "$branch" "$wt"
        log WARN "$__FUNC__" 'It will be transfered to %s\n' "$desired_path"
        log WARN "$__FUNC__" 'to comply with scripts expectations'
        wt=`git_path_compatible "$wt"`
        git worktree move -f -f "$wt" "$wt_new"
    else true; fi
    exit
)

reset_branch() (
    __FUNC__=reset_branch
    branch=$1
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        log WARN "$__FUNC__" 'No head found for refs/heads/%s\n' "$branch"
        exit 0
    fi
    if ! git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        log WARN "$__FUNC__" 'No head found for refs/remotes/origin/%s\n' "$branch"
        exit 0
    fi

    # Compare the refs to skip redundant "git update-ref" invocation
    if [ "`git rev-parse "refs/heads/$branch"`" != "`git rev-parse "refs/remotes/origin/$branch"`" ]; then
        log INFO "$__FUNC__" 'Updating refs/heads/%s to point on refs/remotes/origin/%s\n' "$branch" "$branch"
        git update-ref "refs/heads/$branch" "refs/remotes/origin/$branch"
    fi

    wt=`get_worktree "$branch"`
    wt_compat=`git_path_compatible "$wt"`
    if [ -n "$wt" ]; then
        if [ -n "`git -C "$wt_compat" status --porcelain`" ]; then
            log WARN "$__FUNC__" 'Resetting %s in %s to origin/%s\n' "$branch" "$wt" "$branch"
            git -C "$wt_compat" reset --hard "origin/$branch"
            git -C "$wt_compat" clean -df
        else
            log INFO "$__FUNC__" 'Reset skip: Worktree is clean for refs/heads/%s and up-to-date with refs/remotes/origin/%s\n' "$branch" "$branch"
        fi
    else
        log INFO "$__FUNC__" 'Nothing to reset. Unable to find worktree for refs/heads/%s\n' "$branch"
    fi
    exit 0
)
