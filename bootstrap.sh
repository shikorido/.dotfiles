# DOTFILES management
# master
# bootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

. ./utils/utils.sh
setup_variables

prepare_worktree "$OS"
if [ $? -eq 0 ]; then
    printf %s "$script_dir" >"$OS/.master_root"
    cd "$OS"
    ./bootstrap.sh && rc=0 || rc=1
    cd "$script_dir"
else
    log ERROR master/bootstrap.sh "The current $OS OS is not supported."
    rc=1
fi

if [ "${rc:-0}" -ne 0 ]; then
    log ERROR master/bootstrap.sh "An error occured"
    #log ERROR master/bootstrap.sh "An error occured. Debootstrap will be performed."
    #./debootstrap.sh
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit "${rc:-0}"

