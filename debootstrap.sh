# DOTFILES management
# linux
# debootstrap.sh

branch_ref=linux
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ ! -s .master_root ]; then
    echo "linux/debootstrap.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

setup_variables

propagate_debootstrap "$_OS_ENV_" "$1" || exit

if [ "$_WSL_" ]; then
    propagate_debootstrap wsl "$1"
fi
