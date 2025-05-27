# DOTFILES management
# linux
# debootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

git submodule deinit --all --force 2>/dev/null

# Clear everything unconditionally
for worktree in kali msys2 termux; do
    [ -d "$worktree" ] && {
        cd "$worktree"
        ./debootstrap.sh 2>/dev/null
        cd "$script_dir"
        git worktree remove --force "$worktree" 2>/dev/null
    }
done

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

