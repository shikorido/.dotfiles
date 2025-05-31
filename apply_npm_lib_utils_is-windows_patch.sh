# DOTFILES management
# msys2
# apply_npm_lib_utils_is-windows_patch.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

node_exe=`command -v node.exe`
node_dir=${node_exe%/*}
if [ ! -e "$node_exe" ] || [ ! -e "$node_dir/npm" ]; then
    echo 'Unable to find NodeJS with npm alongside'
    exit 1
fi
if [ ! -e "$node_dir/node_modules/npm/lib/utils/is-windows.js" ]; then
    echo 'Unable to find npm/lib/utils/is-windows.js under NodeJS node_modules'
    exit 1
fi

patch_file=$script_dir/patches/npm_lib_utils_is-windows.patch

if patch --dry-run -stN -p0 -d"$node_dir" <$patch_file >/dev/null; then
    echo 'Applying npm is-windows.js patch...'
    patch -tN -p0 -d"$node_dir" <$patch_file
elif patch --dry-run -stR -p0 -d"$node_dir" <$patch_file >/dev/null; then
    echo 'npm is-windows.js patch was already applied'
else
    echo 'npm is-windows.js patch is no longer applicable'
fi
