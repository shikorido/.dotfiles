# DOTFILES management
# linux
# bootstrap.sh

set -e

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if ! [ -s .master_root ]; then
    echo "linux/bootstrap.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi

master_root=`cat .master_root`

. "$master_root/utils.sh"

setup_variables
install_missing_packages
initialize_submodules

# Preparing worktree
if [ -n "$OS_ENV" ]; then
    git worktree add "$OS_ENV" "$OS_ENV"
    printf "%s" "$master_root" >"$OS_ENV/.master_root"
    cd "$OS_ENV"
    ./bootstrap.sh || rc=1
    cd "$script_dir"
else
    echo "linux/bootstrap.sh: The current env is not supported or does not have specific inner branch."
    rc=1
fi

if [ "$rc" = 1 ]; then
    echo "linux/bootstrap.sh: Error occured. Debootstrap will be performed."
    ./debootstrap.sh
    exit 1
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

