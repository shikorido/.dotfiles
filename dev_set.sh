# DOTFILES management
# master
# dev_set.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

# Worktrees preparation for development
git worktree add linux linux 2>/dev/null
[ -d linux ] && printf "%s" "$script_dir" >linux/.master_root

for worktree in kali msys2 termux; do
    git worktree add "linux/$worktree" "$worktree" 2>/dev/null
    [ -d "linux/$worktree" ] && printf "%s" "$script_dir" >"linux/$worktree/.master_root"
done

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

