# DOTFILES management
# master
# reset_all.sh

script_path=`readlink -f "$0"`
script_dir=${script_path%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

# Make sure everything is up-to-date
[ -z "$IS_FETCHED" ] && git fetch origin && export IS_FETCHED=y

./reset_master.sh "$@"
./reset_other.sh "$@"
