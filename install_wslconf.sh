# DOTFILES management
# wsl
# install_wslconf.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if [ -e /etc/wsl.conf ] && ! [ -f /etc/wsl.conf ]; then
	[ "`id -u`" = 0 ] && {
		timestamp=`date +%s`
		echo "install_wslconf: Renaming /etc/wsl.conf to wsl.conf_$timestamp"
		mv /etc/wsl.conf /etc/wsl.conf_$timestamp
	}
elif [ -f /etc/wsl.conf ]; then
	source_wslconf_hash=`sha256sum wsl.conf | cut -d' ' -f1`
	target_wslconf_hash=`sha256sum /etc/wsl.conf | cut -d' ' -f1`
	[ "$source_wslconf_hash" = "$target_wslconf_hash" ] && skip_wslconf=1
fi
[ "$skip_wslconf" = 1 ] || {
	if [ "`id -u`" = 0 ]; then
		echo "Copying $script_dir/wsl.conf to /etc/wsl.conf"
		cp -u "$script_dir/wsl.conf" /etc/wsl.conf
	else
		echo "install_wslconf: Install dotfiles under root user to be able to install wsl.conf"
	fi
}

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

