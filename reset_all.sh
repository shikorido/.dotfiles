# DOTFILES management
# master
# reset_all.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

# Make sure everything is up-to-date
[ -z "$IS_FETCHED" ] && git fetch origin && export IS_FETCHED=y

[ -f "reset_master.sh" ] && ./reset_master.sh
[ -f "reset_other.sh" ] && ./reset_other.sh

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

