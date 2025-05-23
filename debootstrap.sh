# DOTFILES management
# kali
# debootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

[ "$1" = -f ] || [ "$1" = --force ] && set -- "$1" || set --

if ! [ -s .master_root ]; then
    echo "kali/debootstrap.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

# Setting DOTFILES for every branch individually (cause of splitted configs)
export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

setup_variables

[ -d wsl ] && {
    cd wsl
    ./debootstrap.sh $1
    cd "$script_dir"
    git worktree remove $1 wsl
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

