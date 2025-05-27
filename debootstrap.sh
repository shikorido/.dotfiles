# DOTFILES management
# master
# debootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

[ "$1" = -f ] || [ "$1" = --force ] && set -- "$1" || set --

. ./utils/utils.sh
setup_variables

[ -d "$OS" ] && {
    cd "$OS"
    ./debootstrap.sh $1
    cd "$script_dir"
    git worktree remove $1 "$OS"
    #git worktree remove --force "$OS" 2>/dev/null
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

