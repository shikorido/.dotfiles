# DOTFILES management
# master
# dev_set.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

# Worktrees preparation for development
for worktree in linux windows; do
    git worktree add "$worktree" "$worktree"
    [ -d "$worktree" ] && ! [ "$worktree" = windows ] && printf %s "$script_dir" >"$worktree/.master_root"
done

for worktree in kali msys2 termux; do
    git worktree add "linux/$worktree" "$worktree"
    [ -d "linux/$worktree" ] && printf %s "$script_dir" >"linux/$worktree/.master_root"
done

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

