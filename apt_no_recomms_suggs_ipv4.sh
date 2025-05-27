# DOTFILES management
# linux
# apt_no_recomms_suggs_ipv4.sh

[ "$_PKGMGR_" != apt ] && [ ! "$_TERMUX_" ] && exit

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ ! -s .master_root ]; then
    echo "linux/apt_no_recomms_suggs_ipv4.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`
. "$master_root/utils/utils.sh"
setup_variables

if [ -z "$_TERMUX_" ]; then
    unset PREFIX
else
    [ -z "$PREFIX" ] && PREFIX=/data/data/com.termux/files/usr
    [ ! -d "$PREFIX" ] && echo "linux/install.sh: apt_no_recomms_suggs_ipv4: Termux PREFIX is invalid" && exit 1
fi

echo 'APT::Install-Recommends "false";' >$PREFIX/etc/apt/apt.conf.d/99no-recommends
echo 'APT::Install-Suggests "false";' >$PREFIX/etc/apt/apt.conf.d/99no-suggests
echo 'Acquire::ForceIPv4=true;' >$PREFIX/etc/apt/apt.conf.d/99force-ipv4
