# DOTFILES management
# master
# bootstrap.sh

set -e

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

. ./utils.sh

setup_variables

# Worktrees preparation
if [ "$OS" = linux ]; then
    git worktree add linux linux
    printf "%s" "$script_dir" >linux/.master_root
    cd linux
    ./bootstrap.sh || rc=1
    cd "$script_dir"
else
    echo "The current OS $OS is not supported."
    rc=1
fi

if [ "$rc" = 1 ]; then
    echo "master/bootstrap.sh: Error occured. Debootstrap will be performed."
    ./debootstrap.sh
    exit 1
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

