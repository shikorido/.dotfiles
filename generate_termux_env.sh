# DOTFILES management
# termux
# generate_termux_env.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

[ -z "$PREFIX" ] && PREFIX=/data/data/com.termux/files/usr
termux_env=$PREFIX/etc/termux/termux.env
termux_env_dir=${termux_env%/*}

if [ -s "$termux_env" ]; then
    echo "NOTE: $termux_env exists, remove it if you want to generate a new one"
    exit
fi

if [ ! -O "$PREFIX" ]; then
    echo "In order to generate $termux_env you must execute installation under termux user"
    exit 1
fi

if [ ! -e "$termux_env_dir" ]; then
    mkdir -p "$termux_env_dir"
elif [ ! -d "$termux_env_dir" ]; then
    echo "$termux_env_dir is not a directory! Termux env generation halted"
    exit 1
fi

env_vars=`env | awk '/^(ANDROID_[^=]+|ASEC_MOUNTPOINT|BOOTCLASSPATH|COLORTERM|EXTERNAL_STORAGE|HOME|LANG|LC_[^=]+|LD_PRELOAD|PREFIX|TERM|TERMUX_[^=]+|TMP|SYSTEMSERVERCLASSPATH)=/ {
    if (match($0,/^TERMUX_APP__PID=/)) next
        print $0
    }'`
env_vars=`printf '%s\nPATH=%s/bin' "$env_vars" "$PREFIX"`
env_vars=`printf %s "$env_vars" | awk '{
    sub("=", "=\"")
    print "export " $0 "\""
}' | sort -k 2`
printf %s "$env_vars" >"$termux_env"

echo "NOTE: $termux_env generated"
