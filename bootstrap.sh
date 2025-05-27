# DOTFILES management
# master
# bootstrap.sh

branch_ref=master
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

# Required in propagate_bootstrap.
master_root=$script_dir

. "$master_root/utils/utils.sh"
setup_variables

propagate_bootstrap "$_OS_" OS
