# DOTFILES management
# linux
# debootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

[ "$1" = -f ] || [ "$1" = --force ] && set -- "$1" || set --

if ! [ -s .master_root ]; then
    echo "linux/debootstrap.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

# Setting DOTFILES for every branch individually (cause of splitted configs)
export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

setup_variables

git submodule deinit --all --force 2>/dev/null

[ -d "$OS_ENV" ] && {
    cd "$OS_ENV"
    ./debootstrap.sh $1
    cd "$script_dir"
    git worktree remove $1 "$OS_ENV"
    #git worktree remove --force "$OS_ENV" 2>/dev/null
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0
