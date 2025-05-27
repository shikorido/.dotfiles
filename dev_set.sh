# DOTFILES management
# master
# dev_set.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

. ./utils/git_utils.sh
. ./utils/logger.sh

for br in linux windows kali msys2 termux wsl; do
    if [ "$br" != linux ] && [ "$br" != windows ]; then
        wt=linux/$br
    else
        wt=$br
    fi
    if [ -e "$wt" ]; then
        log ERROR master/dev_set.sh 'Directory entry already exists: %s\n' "$PWD/$wt"
        exit 1
    fi
    git worktree add "$wt" "$br" || exit
    [ "$br" != windows ] && printf %s "$script_dir" >$wt/.master_root
done
