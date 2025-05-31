# DOTFILES management
# msys2
# apply_gh_wrapper_patch.sh

script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
[ "$PWD" != "$script_dir" ] && cd "$script_dir"

[ ! -f "$_MSYSPREF_/bin/gh.exe" ] && echo 'Unable to find gh executable!' && exit 1

patch_file=$script_dir/patches/gh_wrapper.patch

# Guard gh.exe from deletion due to cygwin's nature.
#https://www.cygwin.com/cygwin-ug-net/using-specialnames.html#pathnames-exe
mv "$_MSYSPREF_/bin/gh.exe" "$_MSYSPREF_/bin/gh_orig.exe"
if patch --dry-run -stN -p0 -d"$_MSYSPREF_" <$patch_file >/dev/null; then
    echo 'Applying gh wrapper patch...'
    patch -tN -p0 -d"$_MSYSPREF_" <$patch_file
elif patch --dry-run -stR -p0 -d"$_MSYSPREF_" <$patch_file >/dev/null; then
    echo 'Gh wrapper patch was already applied'
else
    echo 'Gh wrapper patch is no longer applicable'
fi
mv "$_MSYSPREF_/bin/gh_orig.exe" "$_MSYSPREF_/bin/gh.exe"
