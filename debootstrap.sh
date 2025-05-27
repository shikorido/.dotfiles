# DOTFILES management
# master
# debootstrap.sh

branch_ref=master
script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

. ./utils/utils.sh
setup_variables

propagate_debootstrap "$_OS_" "$1"
