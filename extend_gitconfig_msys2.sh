# DOTFILES management
# msys2
# extend_gitconfig_msys2.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

# The main one you usually use
main_config=~/.gitconfig
# The stowed one
local_config=~/.gitconfig.msys2.local

# Ensure main .gitconfig exists
touch "$main_config"

# Prompt for user.name and user.email if not already defined
if ! git config --global user.name >/dev/null 2>&1; then
    printf "Enter your Git user.name: "
    IFS= read name
    git config --global user.name "$name"
    #git config --file "$local_config" user.name "$name"
fi
if ! git config --global user.email >/dev/null 2>&1; then
    printf "Enter your Git user.email: "
    IFS= read email
    git config --global user.email "$email"
    #git config --file "$local_config" user.email "$email"
fi

# Ensure .gitconfig includes .gitconfig.msys2.local
if ! grep -q "path = $local_config" "$main_config"; then
    printf "\n[include]\n\tpath = %s\n" "$local_config" >>"$main_config"
    echo "Added include for $local_config to $main_config"
fi

#echo "Git configuration complete. Summary:"
#git config --file "$local_config" --list

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit 0

