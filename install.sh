# DOTFILES management
# linux
# install.sh

branch_ref=linux
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ ! -s .master_root ]; then
    echo "linux/install.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
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
perform_stow

git_first_time_setup
include_git_config '~/.gitconfig.local'

if [ -d "$_OS_ENV_" ]; then
    propagate_install "$_OS_ENV_"
fi

if [ "$_WSL_" ]; then
    propagate_install wsl
fi
