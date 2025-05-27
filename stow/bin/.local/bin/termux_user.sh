command su --help >/dev/null 2>&1 || {
	echo "Could not find su binary in system for switching to termux user."
	exit 1
}

if [ "`id -u`" = 0 ]; then
	echo "Execution under root detected, skipping su"
	SUDO="/system/bin/sh -c"
else
	# mount master
	SUDO="su -M -c"
fi

[ "`id -u`" = 0 ] && {
	echo "Searching for com.termux UserId at /data/system/packages.list"
	termux_uid=`grep -F "com.termux " /data/system/packages.list | cut -d" " -f2`;
} || {
	[ -e /data/data/com.termux/shared_prefs/com.termux_preferences.xml ] && {
		echo "Looks like you are termux user"
		printf "Proceed further? (y/n) "
		read choice
		case $choice in
			[Yy]*)
				;;
			*)
				exit 0
				;;
		esac
		termux_uid=$(ls -n /data/data/com.termux/shared_prefs/com.termux_preferences.xml | cut -d" " -f3)
	} || {
		termux_uid=$($SUDO "echo \`ls -n /data/data/com.termux/shared_prefs/com.termux_preferences.xml | cut -d\" \" -f3\`")
	}
}
[ -z "$termux_uid" ] && echo "Could not find termux uid" && exit 1
echo "termux_uid: $termux_uid"
termux_uid_cache=2${termux_uid#?}
termux_uid_all=5${termux_uid#?}
# 1007=log, 3003=inet, 9997=everybody
SU="su -g $termux_uid -G 1007 -G 3003 -G 9997 -G $termux_uid_cache -G $termux_uid_all -Z u:r:untrusted_app:s0:c127,c256,c512,c768 - $termux_uid -c"

#echo "Now you will be root within termux environment."
#echo "Make sure to not install/create anything in /data/data/com.termux/files/{home,usr}"
#echo "Otherwise you will fuck up ownerships and SE contexts."
#echo "If you broke something and want to restore ownerships and SE contexts, run the script with \"--restore\" flag."
#echo "It still may harm cause everything under home and usr"
#echo "will be chowned to termux_uid:termux_uid"

while [ $# -ne 0 ]; do
	case $1 in
		#--restore)
		#    RESTORE=y
		#    ;;
		--no-cd)
			NO_CD=y
			;;
		*)
			echo "Unknown arg: \"$1\""
			exit 1
			;;
	esac
	shift
done

export PREFIX=/data/data/com.termux/files/usr
export USER=${PREFIX%/*}/home
[ -d "$USER" ] || mkdir -p "$USER/.tmp"

# termux.env defines TMPDIR at $PREFIX/tmp
#export TMPDIR=\$HOME/.tmp;

$SU \
	"/system/bin/env -i /system/bin/sh -c \
	'. \"$PREFIX/etc/termux/termux.env\"; \
	export HOME=\"$USER\"; \
	export LD_PRELOAD=\$PREFIX/lib/libtermux-exec-ld-preload.so; \
	export TERMUX_APP__PID=\"$TERMUX_APP__PID\"; \
	export SHELL=\$PREFIX/bin/zsh; \
	[ \"$NO_CD\" = y ] || cd \$HOME; \
	\$PREFIX/bin/zsh -l -i'"
