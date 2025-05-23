# DOTFILES management
# kali
# bootstrap.sh

# Should be ran from the worktree root but just in case
script_dir=`readlink -f "$0"`
script_dir=${script_dir%/*}
! [ "$PWD" = "$script_dir" ] && __PWD_OLD=$PWD && cd "$script_dir"

if ! [ -s .master_root ]; then
    echo "kali/bootstrap.sh: $script_dir/.master_root is empty or does not exist! It should point to the root of master branch in order to source utils.sh!"
    exit 1
fi
master_root=`cat .master_root`

# Setting DOTFILES for every branch individually (cause of splitted configs)
export DOTFILES=$script_dir
. "$master_root/utils/utils.sh"

setup_variables

if [ "$WSL" = 1 ]; then
	prepare_worktree wsl
	if [ $? -eq 0 ]; then
		printf %s "$master_root" >"wsl/.master_root"
		cd wsl
		./bootstrap.sh || rc=1
		cd "$script_dir"
	else
		log ERROR kali/bootstrap.sh "Unable to prepare WSL worktree."
		rc=1
	fi
fi

if [ "${rc:-0}" -ne 0 ]; then
    log ERROR kali/bootstrap.sh "An error occured"
    #echo "kali/bootstrap.sh: Error occured. Debootstrap will be performed."
    #./debootstrap.sh
fi

[ -n "$__PWD_OLD" ] && cd "$__PWD_OLD" && unset __PWD_OLD

exit "${rc:-0}"

