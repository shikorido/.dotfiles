# DOTFILES management
# master
# install.sh

# Should be ran from the worktree root but just in case
branch_ref=master
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

. ./utils/utils.sh
setup_variables

propagate_install "$_OS_"
