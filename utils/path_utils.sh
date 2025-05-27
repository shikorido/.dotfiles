# DOTFILES management
# master
# path_utils.sh

[ "$_PATH_UTILS_H" = 1 ] && return 0
_PATH_UTILS_H=1

#reverse_args() (
#    if [ $# = 0 ]; then return; fi
#    first=$1; shift
#    # Subshell environment will inherit __OUTERMOST, so make it empty first.
#    # Variables for `( compound-list )` (subshell env) don't need to be exported, see:
#    #https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_09_04
#    __OUTERMOST=
#    if [ -z "$__REVERSE_ARGS_0443DB6D" ]; then
#        __REVERSE_ARGS_0443DB6D=1
#        # If IFS is set:
#        # - Use first IFS character to simulate word splitting.
#        # - If IFS is null (empty string), __SEP will be null as well.
#        # Else (IFS is unset):
#        # - Use first char of its default value (<space><tab><lf>).
#        if [ "${IFS+x}" ]; then
#            __SEP=${IFS%"${IFS#?}"}
#        else
#            __SEP=' '
#        fi
#        __OUTERMOST=1
#    fi
#    reverse_args "$@"
#    [ "$__OUTERMOST" ] && __SEP=`printf '\nx'` && __SEP=${__SEP%x}
#    printf %s%s "$first" "$__SEP"
#)

# Merely makes absolute logical path, eliminates ., .., prints and returns.
normalize_path() (
    # $PWD gives the same as `pwd -L` and `pwd` (logical path).
    # `pwd -P` and `cd -P` fully resolve symlinks (physical path).
    [ -z "$1" ] && printf '%s\n' "$PWD" && return
    [ -n "${1%%/*}" ] && set -- "$PWD/$1"
    item=$1; set --
    __IFS_OLD=$IFS; IFS=/
    # Keep in mind that field splitting does not occur in ZSH,
    # altough we can set shwordsplit if ZSH is detected, but nuh.
    for tok in `printf %s "$item"`; do
        [ -z "$tok" ] || [ "$tok" = . ] && continue
        if [ "$tok" = .. ]; then
            [ $# = 0 ] && continue
            shift
        else
            set -- "$tok" "$@"
        fi
    done
    IFS=$__IFS_OLD; unset __IFS_OLD
    # Quoted $* is what we need to join by first IFS char.
    # UPD. Since shift only works to the left,
    # we anyway need to loop through arguments in a reverse order.
    # Or somehow remove only the last argument on .. which is more expensive.
    printf /
    ctr=$#
    until [ $ctr = 0 ]; do
        if [ $ctr = 1 ]; then
            printf '%s' "$1"
        else
            eval printf %s/ \"\$$ctr\"
        fi
        ctr=$[ctr - 1]
    done
    printf '\n'
    # awk version
    #printf %s "$1" | awk -v FS=/ '
    #{
    #    for (i = 1; i <= NF; ++i) {
    #        if ($i=="" || $i==".") continue
    #        if ($i=="..") {
    #            if (n > 0) --n
    #        } else {
    #            path[n++] = $i
    #        }
    #    }
    #    printf "/"
    #    for (i = 0; i < n; ++i) {
    #        printf "%s%s", path[i], (i < n-1 ? "/" : "")
    #    }
    #    print ""
    #}'
)

# Behaves very similar to readlink -f.
# Another implementation can be found here:
# https://stackoverflow.com/questions/31596363/how-to-recursively-resolve-symlinks-without-readlink-or-realpath
# While author avoids subprocess forking, we can't simple enough track directory reliably without `cd -P` into.
# Also I assume readlink is present which may not be the case for OS X? Whatever.
# How to resolve non-directory symlink within a posix shell just like 'cd -P' and 'pwd -P'?
# This way readlink could be completely avoided.
# UPD. Added ls parsing but it might not work in some cases.
# Yes, I use 'readlink -f' in scripts header to cd into resolved script's directory.
# The implementation was left just for reference.
# Error messages are not suppressed to make the cause easier to understand.
readlinkf() (
    item=$1
    # Standardized resolution of symlinks pointing to a directory.
    if [ -d "$item" ]; then
        cd -P "$item" && pwd || exit 1
        exit
    fi
    # Always convert to absolute logical path.
    item=`normalize_path "$item"`
    # If target does not exist, but parent dir does - resolve parent dir.
    # UPD. This code path takes place with circular symlinks as well,
    #      but we can actually parse cd error message "Too many levels of symbolic links".
    if [ ! -e "$item" ]; then
        # Circular reference detection.
        case `LC_ALL=C cd "$item" 2>&1 >/dev/null` in
            *"Too many levels of symbolic links"*)
                echo 'Circular reference or too many levels of symbolic links (40+)' >&2
                exit 1
        esac
        cd -P "${item%/*}" 2>/dev/null || exit 1
        printf '%s\n' "$PWD/${item##*/}"
        exit
    fi
    while [ -L "$item" ]; do
        cd -P "${item%/*}"
        target=`LC_ALL=C ls -ldn "$item"` || exit 1
        target=${target#* "$item" -> }
        # If something went wrong in ls output parsing - fallback to readlink.
        # For example, nasty filename characters, quoted filenames in output.
        if [ -e "$target" ]; then
            item=$target
        else
            item=`readlink "$item"` || exit 1
        fi
        item=`normalize_path "$item"`
    done
    printf '%s\n' "$item"
)
