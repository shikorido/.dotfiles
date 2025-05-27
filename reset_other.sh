# DOTFILES management
# master
# reset_other.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

. ./utils/git_utils.sh

# Make sure everything is up-to-date
[ -z "$IS_FETCHED" ] && git fetch origin && export IS_FETCHED=y

for branch in `git for-each-ref --format='%(refname:short)' refs/heads/`; do
    [ "$branch" = "master" ] && continue
    reset_branch "$branch"
done

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

