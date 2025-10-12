# DOTFILES management
# wsl
# install.sh

branch_ref=wsl
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ ! -s .master_root ]; then
    echo "wsl/install.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

setup_variables
check_dotfiles
prepare_stow_packages
check_conflicts
perform_stow

./install_wslconf.sh
