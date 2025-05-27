# DOTFILES management
# termux
# apply_pulseaudio_patch.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if ! [ -d ~/../usr/etc/pulse ]; then
    echo "Termux pulseaudio configs were not found in $HOME/../usr/etc/pulse"

    echo "Checking whether pulseaudio is installed."
    if dpkg -L pulseaudio >/dev/null 2>&1; then
        echo "Pulseaudio installed, performing reinstall to restore the package state..."
        pkg reinstall -y pulseaudio
    else
        echo "Pulseaudio not installed, performing installation..."
        pkg install -y pulseaudio
    fi
fi

patch_file=$script_dir/patches/termux_pulseaudio.patch

cd ~/..
if patch --dry-run --batch --forward -p0 <"$patch_file" >/dev/null 2>&1; then
    echo "Applying termux pulseaudio patch..."
    patch --batch --forward -p0 <"$patch_file"
else
    echo "Termux pulseaudio patch was already applied or not applicable."
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

