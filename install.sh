# DOTFILES management
# termux
# install.sh

branch_ref=termux
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ ! -s .master_root ]; then
    echo "termux/install.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
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

# Ignore hererocks error cause it is not used right now.
./apply_hererocks_patch.sh
./apply_pulseaudio_patch.sh
./generate_termux_env.sh
