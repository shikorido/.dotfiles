# DOTFILES management
# master
# dev_unset.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

[ "$1" = -f ] || [ "$1" = --force ] && set -- "$1" || set --

. ./utils/git_utils.sh
. ./utils/logger.sh

for br in kali msys2 termux wsl linux windows; do
    if [ "$br" != linux ] && [ "$br" != windows ]; then
        wt=linux/$br
    else
        wt=$br
    fi
    if [ -d "$wt" ]; then
        if [ "$1" ]; then
            :
        elif ! git -C "$wt" submodule deinit --all 2>/dev/null; then
            log ERROR master/dev_unset.sh 'Submodules are dirty in worktree: %s\n' "$PWD/$wt"
            exit 1
        elif ! is_clean_git_status "$wt"; then
            log ERROR master/dev_unset.sh 'Worktree is dirty: %s\n' "$PWD/$wt"
            git -C "$wt" status -s
            exit 1
        fi
        git worktree remove -f "$wt"
    fi
done
