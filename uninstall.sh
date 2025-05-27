# DOTFILES management
# linux
# uninstall.sh

branch_ref=linux
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ ! -s .master_root ]; then
    echo "linux/uninstall.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

INCLUDE_SUBMODULES=y

setup_variables
check_dotfiles
prepare_stow_packages
check_conflicts
perform_unstow

uninclude_git_config '~/.gitconfig.local'

propagate_uninstall "$_OS_ENV_" || exit

[ "$_WSL_" ] && propagate_uninstall wsl
