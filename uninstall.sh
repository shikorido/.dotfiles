# DOTFILES management
# msys2
# uninstall.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if ! [ -s .master_root ]; then
    echo "msys2/uninstall.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

# Setting DOTFILES for every branch individually (cause of splitted configs)
export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

setup_variables
check_dotfiles
prepare_stow_packages
check_conflicts
perform_unstow

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

