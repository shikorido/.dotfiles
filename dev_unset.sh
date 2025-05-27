# DOTFILES management
# master
# dev_unset.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

# Worktrees removal
for worktree in kali msys2 termux; do
    [ -d "$worktree" ] && {
        git worktree remove --force "$worktree" 2>/dev/null
    }
done

git worktree remove --force linux 2>/dev/null

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0


