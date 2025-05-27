# DOTFILES management
# termux
# generate_termux_env.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

[ -z "$PREFIX" ] && PREFIX=/data/data/com.termux/files/usr
termux_env=$PREFIX/etc/termux/termux.env

if ! [ -s "$termux_env" ]; then
	[ -O "$PREFIX" ] || {
		echo "In order to generate $termux_env you must execute installation under termux user."
		exit 1
	}
	env_vars=`env | awk '/^(ANDROID_[^=]+|ASEC_MOUNTPOINT|BOOTCLASSPATH|COLORTERM|EXTERNAL_STORAGE|HOME|LANG|LC_[^=]+|LD_PRELOAD|PREFIX|TERM|TERMUX_[^=]+|TMP|SYSTEMSERVERCLASSPATH)=/ {
		#[^[:space:]]/
		if (match($0,/^TERMUX_APP__PID=/)) next
		print $0
	}'`
	env_vars=`printf "%s\nPATH=$PREFIX/bin" "$env_vars"`
	env_vars=`printf %s "$env_vars" | awk '{
		sub("=", "=\"")
		print "export " $0 "\""
	}' | sort -k 2`
	printf %s "$env_vars" >"$termux_env"
	echo "NOTE: $termux_env generated."
else
	echo "NOTE: $termux_env exists, remove it if you want to generate a new one."
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

