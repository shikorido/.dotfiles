# DOTFILES management
# master
# path_utils.sh

[ "$_PATH_UTILS_H" = 1 ] && return 0
_PATH_UTILS_H=1

# Merely makes absolute logical path, eliminates ., .., prints and returns.
normalize_path() {
    # $PWD gives the same as `pwd -L` and `pwd` (logical path).
    # `pwd -P` and `cd -P` fully resolve symlinks (physical path).
    [ -z "$1" ] && printf "%s\n" "$PWD"
    [ -n "${1%%/*}" ] && set -- "$PWD/$1"
    printf %s "$1" | awk '
    BEGIN{FS="/"} {
        for (i = 1; i <= NF; ++i) {
            if ($i=="" || $i==".") continue
            if ($i=="..") {
                if (n > 0) --n
            } else {
                path[n++] = $i
            }
        }
        printf "/"
        for (i = 0; i < n; ++i) {
            printf "%s%s", path[i], (i < n-1 ? "/" : "")
        }
        print ""
    }'
}
# Behaves very similar to readlink -f
# Another implementation can be found here:
# https://stackoverflow.com/questions/31596363/how-to-recursively-resolve-symlinks-without-readlink-or-realpath
# While author avoids subprocess forking, we can't simple enough track directory reliably without `cd -P` into.
# Also I assume readlink is present which may not be the case for OS X? Whatever.
# Yes, I use 'readlink -f' in scripts header to cd into resolved script's directory.
# The implementation was left just in case.
readlinkf() (
    item=$1
    # Always convert to absolute logical path.
    item=`normalize_path "$item"`
    [ -d "$item" ] && IS_DIR=y || unset IS_DIR
    while [ -L "$item" ]; do
        #dir=`cd -P "$item" >/dev/null 2>&1 && pwd`
        if [ "$IS_DIR" ]; then
            cd -P "$item"
            item=$PWD
        else
            cd -P "${item%/*}"
            # How to resolve file link within a posix shell just like 'cd -P' and 'pwd -P'?
            item=`readlink "$item"`
        fi
        item=`normalize_path "$item"`
    done
    printf "%s\n" "$item"
)

