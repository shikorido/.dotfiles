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
# Since zsh is already working in posix emulation layer (msys/cygwin),
# both cygwin and windows gits work fine. However, do note that
# git for windows stucks on occasional deadlock when called
# from emulation layer. I don't really know what causes it at the moment,
# but it can interrupted with Ctrl+ScrolLock or Ctrl+Pause
# (both trigger Break but with different scan codes).
# Break emits interruption signal just like Ctrl+C,
# latter can be overriden unlike former.
#https://learn.microsoft.com/en-us/windows/console/ctrl-c-and-ctrl-break-signals?redirectedfrom=MSDN
_GIT_FLAVOR=posix

if command -v cygpath >/dev/null; then
    git_path_posix() {
        [ -z "$1" ] && return
        printf %s "`cygpath -a "$1"`"
    }
else
    git_path_posix() {
        [ -z "$1" ] && return
        case $1 in
            /*) printf %s "$1";;
            *) printf %s "$PWD/$1"
        esac
    }
fi

git_path_windows() {
    [ -z "$1" ] && return
    printf %s "`cygpath -am "$1"`"
}

# Assume posix by default.
# This function will be redefined in case of windows git.
git_path_compatible() {
    git_path_posix "$1"
}

# Determine git flavor in this file instead of relying on setup_variables.
determine_git_flavor() {
    if [ "$VARIABLES_SETTED_UP" ]; then
        [ "$_MSYS2_" ] || return 0
    else
        case `uname` in *MINGW*|*MSYS*);; *) return 0; esac
    fi
    case `git --exec-path` in
        /*);;
        ?:*)
            _GIT_FLAVOR=windows
            git_path_compatible() {
                git_path_windows "$1"
            };;
        *)
            log ERROR 'Unknown git flavor from `git --exec-path` output'
            return 1
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
    # Inefficient on every call, but still.
    git worktree prune
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
    if [ $# = 1 ]; then
        [ "$1" = "${1#*/}" ] || exit
        branch=$1
    elif [ $# = 2 ]; then
        [ "$2" = "${2#*/}" ] || exit
        branch=$2
    else
        exit 1
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

# Ignores submodules (default).
# $1 - repo path, defaults to PWD
is_clean_git_status() {
    if [ $# = 0 ]; then
        set -- "$PWD"
    elif [ $# != 1 ]; then
        log ERROR is_clean_git_status 'Too many arguments provided, expected 1 (path to any git repo)'
        return 1
    elif [ ! -d "$1" ]; then
        log ERROR is_clean_git_status 'Given git repo path does not exist: %s\n' "$1"
    fi
    [ -z "`git -C "$1" status --porcelain`" ]
}

# By default, hard reset branch to its HEAD.
# If -r or -R<refname> provided, hard reset to origin or <refname> remote.
reset_branch() (
    __FUNC__=reset_branch
    unset branch remote
    until [ $# = 0 ]; do
        case $1 in
            -r) remote=origin;;
            -R) shift; remote=$1;;
            --) shift; branch=$1; break;;
            -*)
                log ERROR "$__FUNC__" 'Unknown option: %s\n' "$1"
                exit 1;;
            *) branch=$1
        esac
        shift
    done
    [ -z "$branch" ] && log ERROR "$__FUNC__" 'No branch provided' && exit 1

    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        log WARN "$__FUNC__" 'No head found for refs/heads/%s\n' "$branch"
        exit 0
    fi

    if [ -n "$remote" ]; then
        if ! git show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
            log WARN "$__FUNC__" 'No head found for refs/remotes/%s/%s\n' "$remote" "$branch"
            exit 0
        fi

        # Compare the refs to skip redundant "git update-ref" invocation
        if [ "`git rev-parse "refs/heads/$branch"`" != "`git rev-parse "refs/remotes/$remote/$branch"`" ]; then
            log INFO "$__FUNC__" 'Updating refs/heads/%s to point on refs/remotes/%s/%s\n' "$branch" "$remote" "$branch"
            git update-ref "refs/heads/$branch" "refs/remotes/$remote/$branch"
        fi
    fi

    wt=`get_worktree "$branch"`
    wt_compat=`git_path_compatible "$wt"`
    if [ -z "$wt" ]; then
        log INFO "$__FUNC__" 'Nothing to reset. Unable to find worktree for refs/heads/%s\n' "$branch"
        exit 0
    fi
    if is_clean_git_status "$wt_compat"; then
        if [ -z "$remote" ]; then
            log INFO "$__FUNC__" 'Reset skip: Worktree is clean for refs/heads/%s\n' "$branch"
        else
            log INFO "$__FUNC__" 'Reset skip: Worktree is clean for refs/heads/%s and up-to-date with refs/remotes/%s/%s\n' "$branch" "$remote" "$branch"
        fi
        exit 0
    fi
    if [ -z "$remote" ]; then
        log WARN "$__FUNC__" 'Resetting %s in "%s"\n' "$branch" "$wt"
        git -C "$wt_compat" reset --hard
    else
        log WARN "$__FUNC__" 'Resetting %s in "%s" to %s/%s\n' "$branch" "$wt" "$remote" "$branch"
        git -C "$wt_compat" reset --hard "$remote/$branch"
    fi
    git -C "$wt_compat" clean -df

    exit 0
)

git_first_time_setup() {
    # Prompt for user.name and user.email if not already defined
    if ! git config --global user.name >/dev/null 2>&1; then
        printf 'Enter your Git user.name: '
        IFS= read name
        git config --global user.name "$name"
    fi
    if ! git config --global user.email >/dev/null 2>&1; then
        printf 'Enter your Git user.email: '
        IFS= read email
        git config --global user.email "$email"
    fi
}

# $1 - path to git config to include (can begin with ~/, or ~name/)
include_git_config() (
    __FUNC__=include_git_config
    if [ $# = 0 ]; then
        log ERROR "$__FUNC__" 'No path to config to include provided'
        exit 1
    elif [ $# != 1 ]; then
        log ERROR "$__FUNC__" 'Too many arguments provided, expected 1'
        exit 1
    fi
    case $1 in
        \~/*)
            cfg=~/${1#\~/};;
        \~*/*)
            tilde=${1%%/*}
            usr=${tilde#\~}
            rest=${1#*/}
            # Forbidden usernames in Windows (most likely not full list):
            # 1. May not contain characters: \ / " [] : | < > + = ; , ? * @ <TAB> <NUL>
            # 2. May not consist entirely of periods and/or spaces.
            #
            # Forbidden usernames in Linux (most likely not full list):
            # 1. May not contain characters: : <NUL>
            # / is allowed, but home directory becomes nested.
            #
            # Username pattern, that can be expanded in shell.
            # As for * ? [], path globbing does not take place.
            # For !, bash can enable history expansion in scripts (pointless at most).
            # For {a,b}, brace expansion must be disabled (options differ between shells).
            # For {1..5} and {a..f}, it's Zsh numeric/character ranges.
            # For :, disallowed on Windows (username+filename) and Unix (username, /etc/passwd write error).
            # [][!%*+,.[:alnum:]=?@^_{}~-]
            #
            # Although, these are only ASCII characters,
            # username can contain unicode characters as well.
            # In this case, the best thing is a pattern that excludes
            # characters that are special for shell parser (including {}),
            # forbidden by username invariant, fail tilde expansion
            # (plus some additional strictness).
            # [[:cntrl:][:space:]\"\''!#$&()/:;<>\`|{}']
            #
            # Otherwise, fallback to getent, /etc/passwd, $PREFIX/etc/passwd.
            case $usr in
                # Negative brace expression can be avoided using ${a#*BE} and equality check.
                *[![:cntrl:][:space:]\"\''!#$&()/:;<>\`|{}']*)
                    # Should be eligible to shell tilde expansion.
                    tildeable=1;;
                *)
                    tildeable=
            esac
            if command -v getent >/dev/null && getent passwd "$usr" >/dev/null; then
                usrhome=`getent passwd "$usr" | cut -d: -f6`
            elif [ -f /etc/passwd ] && grep -qs "^$usr:" /etc/passwd; then
                usrhome=`grep "^$usr:" /etc/passwd | cut -d: -f6`
            elif [ -f "$PREFIX/etc/passwd" ] && grep -qs "^$usr:" "$PREFIX/etc/passwd"; then
                usrhome=`grep "^$usr:" "$PREFIX/etc/passwd" | cut -d: -f6`
            elif [ "$tildeable" ]; then
                eval "usrhome=~$usr"
                [ "${usrhome#\~}" = "$usrhome" ] || usrhome=
            fi
            if [ ! -d "${usrhome}" ]; then
                log ERROR "$__FUNC__" 'Non-existent home directory for user: %s\n' "$usr"
                exit 1
            fi
            cfg=$usrhome/$rest;;
        *)
            cfg=$1
    esac
    log DEBUG "$__FUNC__" 'cfg=%s\n' "$cfg"
    if [ ! -e "$cfg" ]; then
        log ERROR "$__FUNC__" 'Non-existent git config to include: %s\n' "$cfg"
        exit 1
    elif [ ! -f "$cfg" ]; then
        log ERROR "$__FUNC__" 'Git config to include is not a file: %s\n' "$cfg"
        exit 1
    fi
    # For new git versions.
    #git config get --global --fixed-value --value "$1" include.path >/dev/null
    #git config set --global --append include.path "$1"
    if ! git config --global --fixed-value --get include.path "$1" >/dev/null; then
        git config --global --add include.path "$1"
        log INFO "$__FUNC__" 'Added git include %s\n' "$1"
    fi
    # Do not use. Rewritten using `git config`.
    #if ! grep -q "path = $2" "$1"; then
    #    printf "\n[include]\n\tpath = %s\n" "$local_config_unexp" >>$main_config
    #    echo "Added include for $local_config to $main_config"
    #fi
)

uninclude_git_config() {
    if [ $# = 0 ]; then
        log ERROR uninclude_git_config 'No path to config to uninclude provided'
        exit 1
    elif [ $# != 1 ]; then
        log ERROR uninclude_git_config 'Too many arguments provided, expected 1'
        exit 1
    fi
    # For new git versions.
    #git config unset --global --fixed-value --value "$1" include.path
    git config --global --fixed-value --unset include.path "$1"
    :
}



# Execute this after functions definitions.
determine_git_flavor || exit 1
