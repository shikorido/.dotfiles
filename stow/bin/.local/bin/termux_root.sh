[ "`id -u`" = 0 ] || command su --help >/dev/null 2>&1 || {
	echo "Could not find su binary in system, looks like you have no root."
	exit 1
}

echo "Now you will be root within termux environment."
echo "Make sure to not install/create anything in /data/data/com.termux/files/{home,usr}"
echo "Otherwise you will fuck up ownerships and SE contexts."
echo "If you broke something and want to restore ownerships and SE contexts, run the script with \"--restore\" flag."
echo "It still may harm cause everything under home and usr"
echo "will be chowned to termux_uid:termux_uid"

while [ $# -ne 0 ]; do
	case $1 in
		--restore)
			RESTORE=y
			;;
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

if [ "`id -u`" = 0 ]; then
	echo "Execution under root detected, skipping su"
	SUDO="/system/bin/sh -c"
else
	# mount master
	SUDO="su -M -c"
fi

[ "$RESTORE" = y ] && {
	echo "Searching for com.termux UserId at /data/system/packages.list"
	$SUDO \
		"/system/bin/env -i /system/bin/sh -c \
		'termux_uid=\`grep -F \"com.termux \" /data/system/packages.list | cut -d\" \" -f2\`; \
		echo \"termux_uid: \$termux_uid\"; \
		echo \"Continue? (y/n) \"; \
		read choice; \
		case \$choice in \
			y*) \
				chown -h -R \$termux_uid:\$termux_uid /data/data/com.termux/files/home; \
				chown -h -R \$termux_uid:\$termux_uid /data/data/com.termux/files/usr; \
				restorecon -R /data/data/com.termux/files/home; \
				restorecon -R /data/data/com.termux/files/usr; \
				echo \"Done.\" \
				;; \
			*) \
				echo \"Cancelled.\" \
				;; \
		esac \
		'"
	exit
}

export PREFIX=/data/data/com.termux/files/usr
export ROOT=${PREFIX%/*}/root
[ -d "$ROOT" ] || mkdir -p "$ROOT/.tmp"

$SUDO \
	"/system/bin/env -i /system/bin/sh -c \
	'. \"$PREFIX/etc/termux/termux.env\"; \
	export HOME=\"$ROOT\"; \
	export TMPDIR=\$HOME/.tmp; \
	export LD_PRELOAD=\$PREFIX/lib/libtermux-exec-ld-preload.so; \
	export TERMUX_APP__PID=\"$TERMUX_APP__PID\"; \
	export SHELL=\$PREFIX/bin/zsh; \
	[ \"$NO_CD\" = y ] || cd \$HOME; \
	\$PREFIX/bin/zsh -l -i'"
