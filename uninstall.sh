# DOTFILES management
# master
# uninstall.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

. ./utils/utils.sh
setup_variables

[ -d "$OS" ] && {
    cd "$OS"
    [ -f uninstall.sh ] && ./uninstall.sh
    cd "$script_dir"
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

