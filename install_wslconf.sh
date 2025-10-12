# DOTFILES management
# wsl
# install_wslconf.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

if [ -f /etc/wsl.conf ]; then
    source_wslconf_hash=`sha256sum wsl.conf | cut -d' ' -f1`
    target_wslconf_hash=`sha256sum /etc/wsl.conf | cut -d' ' -f1`
    if [ "$source_wslconf_hash" = "$target_wslconf_hash" ]; then
        echo 'wsl/install_wslconf.sh: /etc/wsl.conf was already installed'
        exit
    fi
fi

if [ "`id -u`" != 0 ]; then
    echo 'wsl/install_wslconf.sh: Skipping /etc/wsl.conf installation due to insufficient privileges'
    exit 1
fi

if [ -e /etc/wsl.conf ]; then
    timestamp=`date +%s`
    echo "wsl/install_wslconf.sh: Renaming /etc/wsl.conf to wsl.conf_$timestamp"
    mv /etc/wsl.conf /etc/wsl.conf_$timestamp
fi

echo "wsl/install_wslconf.sh: Copying $script_dir/wsl.conf to /etc/wsl.conf"
cp "$script_dir/wsl.conf" /etc/wsl.conf
