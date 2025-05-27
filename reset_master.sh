# DOTFILES management
# master
# reset_master.sh

script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

. ./utils/git_utils.sh

[ -z "$IS_FETCHED" ] && git fetch origin && export IS_FETCHED=y

reset_branch master "$@"
