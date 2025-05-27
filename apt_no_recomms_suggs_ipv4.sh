# DOTFILES management
# linux
# apt_no_recomms_suggs_ipv4.sh

set -e

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if ! [ -s .master_root ]; then
    echo "linux/install.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`
. "$master_root/utils/utils.sh"
setup_variables

[ "$DEBIAN" = 1 ] && {
    echo 'APT::Install-Recommends "false";' >/etc/apt/apt.conf.d/99no-recommends
    echo 'APT::Install-Suggests "false";' >/etc/apt/apt.conf.d/99no-suggests
    echo 'Acquire::ForceIPv4=true;' >/etc/apt/apt.conf.d/99force-ipv4
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

