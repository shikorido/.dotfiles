# DOTFILES management
# master
# debootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

[ -d linux ] && {
    cd linux
    ./debootstrap.sh 2>/dev/null
    cd "$script_dir"
    git worktree remove --force linux 2>/dev/null
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

