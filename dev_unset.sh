# DOTFILES management
# master
# dev_unset.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

[ "$1" = -f ] || [ "$1" = --force ] && set -- "$1" || set --

# Worktrees removal
for worktree in kali msys2 termux; do
    [ -d "linux/$worktree" ] && {
        git worktree remove $1 "linux/$worktree"
    }
done

for worktree in linux windows; do
    git worktree remove $1 "$worktree"
done

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0


