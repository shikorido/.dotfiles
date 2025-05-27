# DOTFILES management
# termux
# apply_hererocks_patch.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if ! [ -d ~/.local/share/nvim/lazy-rocks/hererocks ]; then
    echo "Hererocks was not found in $HOME/.local/share/nvim/lazy-rocks/hererocks"

    echo "Running nvim until hererocks throws any error."
    if ! (nvim --headless +qa 2>&1 | grep -qF "luarocks/core/sysdetect.lua"); then
        echo "Could not find hererocks-related error string."
        exit 1
    fi
    ! [ -d ~/.local/share/nvim/lazy-rocks/hererocks ] && {
        echo "Hererocks still was not found in $HOME/.local/share/nvim/lazy-rocks/hererocks"
        echo "Make sure the plugins are stowed (run nvim manually and see what happens)."
        exit 1
    }
fi

patch_file=$script_dir/patches/termux_hererocks.patch

cd ~
if patch --dry-run --batch --forward -p0 <"$patch_file" >/dev/null 2>&1; then
    echo "Applying termux hererocks patch..."
    patch --batch --forward -p0 <"$patch_file"
else
    echo "Termux hererocks patch was already applied or not applicable."
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

