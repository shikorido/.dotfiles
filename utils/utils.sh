# DOTFILES management
# master
# utils.sh

[ "$_UTILS_H" = 1 ] && return 0
_UTILS_H=1
. "${master_root:-.}/utils/logger.sh"
. "${master_root:-.}/utils/git_utils.sh"

# OS - initial workree to checkout under master
# OS_ENV - secondary worktree to checkout under OS
# LINUX - 1 if linux distro
# MSYS2 - 1 if msys2 of any kind (installer adds mingw64 packages, it is not generalized)
# TERMUX - 1 if termux env
# WSL - 1 if wsl
# LINUX_DISTRO - linux distro str if LINUX is 1
# PKGMGR - package manager str
setup_variables() {
    [ -n "$VARIABLES_SETTED_UP" ] && return

    # Make sure the following variables are unset
    unset ID _LINUX_ _MSYS2_ _TERMUX_ _WSL_ _OS_ _OS_ENV_ _LINUX_DISTRO_ _PKGMGR_
    unset _MSYSPREF_ _MSYSPKGPREF_

    # General OS detection, will be tweaked to linux if MSYS2 is detected
    _OS_=`uname | tr '[:upper:]' '[:lower:]'`

    # MSYS2 detection (any kind)
    #printf %s "$_OS_" | grep -q -i 'MINGW64_NT\|MINGW32_NT\|MSYS_NT' && ID=msys2
    case $_OS_ in *mingw*|*msys*) ID=msys2; esac

    # Termux detection (double check)
    [ -z "$ID" ] && [ "$TERMUX_VERSION" ] && ID=termux
    [ -z "$ID" ] && [ -d /data/data/com.termux ] && ID=termux

    # Linux distro detection, msys2 also has this file
    [ -z "$ID" ] && [ -f /etc/os-release ] && . /etc/os-release

    case $ID in
        debian|kali|ubuntu)
            _PKGMGR_=apt
            _LINUX_=1;;
        alpine)
            _PKGMGR_=apk
            _LINUX_=1;;
        msys2)
            _PKGMGR_=pacman
            _MSYS2_=1;;
        termux)
            # Termux's pkg is a wrapper around apt, and it can resolve
            # issues when apt is unable to download packages.
            _PKGMGR_=pkg
            _TERMUX_=1;;
        *) # I have no experience with other PMs yet
            log ERROR setup_variables 'Unknown system ID: %s\n' "$ID"
            exit 1
    esac

    if [ "$_MSYS2_" ]; then
        case $MSYSTEM in
            UCRT64|CLANG64|CLANGARM64);;
            MINGW32|MINGW64)
                log WARN setup_variables "Current MSYSTEM ($MSYSTEM) is deprecated!"
                log WARN setup_variables 'For more information, see https://www.msys2.org/docs/environments/';;
            CLANG32)
                log ERROR setup_variables "Current MSYSTEM ($MSYSTEM) is obsolete! MSYS2 has dropped it entirely"
                log ERROR setup_variables 'For more information, see https://www.msys2.org/docs/environments/'
                exit 1;;
            MSYS)
                log WARN setup_variables 'MSYSTEM is MSYS. Native packages installation (UCRT/CLANG/MINGW) will be skipped';;
            *?*)
                # In this case, /etc/msystem.d/MSYS should be sourced
                # and MSYSTEM set to MSYS, but this branch means that
                # MSYSTEM was changed somewhere.
                log ERROR setup_variables "Unknown MSYSTEM ($MSYSTEM)! Ensure MSYSTEM is correct before dotfiles installation"
                exit 1;;
            *)
                # Impossible unless explicitly unset or /etc/msystem was skipped.
                log ERROR setup_variables 'MSYSTEM is unset or null! Ensure MSYSTEM is correct before dotfiles installation'
                exit 1;;
        esac

        # Usage:
        # MSYS    = ${_MSYSPKGPREF_}patch  = patch
        # CLANG64 = ${_MSYSPKGPREF_}neovim = mingw-w64-clang-x86_64-neovim
        case $MSYSTEM in
            UCRT64)
                _MSYSPREF_=/ucrt64
                _MSYSPKGPREF_=mingw-w64-ucrt-x86_64-;;
            CLANG64)
                _MSYSPREF_=/clang64
                _MSYSPKGPREF_=mingw-w64-clang-x86_64-;;
            CLANGARM64)
                _MSYSPREF_=/clangarm64
                _MSYSPKGPREF_=mingw-w64-clang-aarch64-;;
            MSYS)
                _MSYSPREF_=/usr
                _MSYSPKGPREF_=;;
            MINGW64)
                _MSYSPREF_=/mingw64
                _MSYSPKGPREF_=mingw-w64-x86_64-;;
            MINGW32)
                _MSYSPREF_=/mingw32
                _MSYSPKGPREF_=mingw-w64-i686-;;
        esac
    fi

    [ "$_LINUX_" ] && _LINUX_DISTRO_=$ID

    # WSL detection to exclude kex from installing
    #uname -r | grep -q WSL && _WSL_=1
    case `uname -r` in *WSL*) _WSL_=1; esac

    # Sanity check
    if [ $(( ${_LINUX_:-0} + ${_MSYS2_:-0} + ${_TERMUX_:-0} )) != 1 ]; then
        log ERROR setup_variables \
            'Only one of _LINUX_ (%s), _MSYS2_ (%s), or _TERMUX_ (%s) must be defined! Terminating...\n' \
            "${_LINUX_:-null}" "${_MSYS2_:-null}" "${_TERMUX_:-null}"
        exit 1
    fi

    # Tweaking OS in case of MSYS2 and termux, they both use linux worktree.
    # Although, linux worktree will always be used since sh files are executing.
    [ "$_MSYS2_" ] || [ "$_TERMUX_" ] && _OS_=linux

    # Setting up the OS_ENV variable for inner worktree
    _OS_ENV_=$ID

    if [ -z "$PRINT_INFO" ]; then
        [ -f ~/.zsh_env_persistent ] && rm -f ~/.zsh_env_persistent
        log INFO setup_variables 'Inferred environment variables:'
        for var in _LINUX_ _MSYS2_ _TERMUX_ _WSL_ _OS_ _OS_ENV_ \
            _LINUX_DISTRO_ _PKGMGR_ _MSYSPREF_ _MSYSPKGPREF_; do
            log INFO setup_variables '%12s: %s\n' "$var" "`eval printf %s '"$'$var'"'`"
            # Make variables persistent to source from dotfiles.
            # Should they be exported? I guess, not really, but why not?
            printf 'export %s=%s\n' "$var" "`eval printf %s '"$'$var'"'`" >>~/.zsh_env_persistent
        done
        >>~/.zsh_env_persistent cat <<\EOF
if [[ "$_MSYS2_" ]]; then
    case $MSYSTEM in
        UCRT64)
            _MSYSPREF_=/ucrt64
            _MSYSPKGPREF_=mingw-w64-ucrt-x86_64-;;
        CLANG64)
            _MSYSPREF_=/clang64
            _MSYSPKGPREF_=mingw-w64-clang-x86_64-;;
        CLANGARM64)
            _MSYSPREF_=/clangarm64
            _MSYSPKGPREF_=mingw-w64-clang-aarch64-;;
        MSYS)
            _MSYSPREF_=/usr
            _MSYSPKGPREF_=;;
        MINGW64)
            _MSYSPREF_=/mingw64
            _MSYSPKGPREF_=mingw-w64-x86_64-;;
        MINGW32)
            _MSYSPREF_=/mingw32
            _MSYSPKGPREF_=mingw-w64-i686-;;
    esac
    export _MSYSPREF_ _MSYSPKGPREF_
fi
EOF
        export PRINT_INFO=n
    fi

    unset ID
    export _LINUX_ _MSYS2_ _TERMUX_ _WSL_ _OS_ _OS_ENV_ _LINUX_DISTRO_ _PKGMGR_
    export _MSYSPREF_ _MSYSPKGPREF_
    export VARIABLES_SETTED_UP=y

    return 0
}

add_missing() {
    while [ $# != 0 ]; do
        if [ -z "$MISSING" ]; then
            MISSING=$1
        else
            MISSING="$MISSING $1"
        fi
        shift
    done
}

install_missing_packages() (
    # Determine which command will serve as SUDO
    if [ "$_LINUX_" ]; then
        if command -v sudo >/dev/null; then
            log INFO install_missing_packages 'Using sudo as superuser cmd'
            SUDO='sudo sh -c'
        elif command -v su >/dev/null; then
            log WARN install_missing_packages 'Unable to find sudo'
            log WARN install_missing_packages 'Using su -c as superuser cmd'
            SUDO='su -c'
        else
            log ERROR install_missing_packages 'Unable to find privilege escalation utility (sudo, su)'
            log ERROR install_missing_packages 'Using "sh -c" may result in insufficient privileges'
            SUDO='sh -c'
        fi
    else
        SUDO='sh -c'
        # In termux, we can't run pkg under root,
        # so here is the right place for a command
        # that runs pkg under termux user.
        if [ "$_TERMUX_" ] && [ "`id -u`" = 0 ]; then
            termux_uid=`grep -F 'com.termux ' /data/system/packages.list | cut -d' ' -f2`
            case $termux_uid in
                # Normally, history expansion should be disabled in scripts,
                # so it should be fine to use ! here.
                *[![:digit:]]*|'')
                    log ERROR install_missing_packages 'Unable to extract com.termux uid from /data/system/packages.list'
                    exit 1
            esac
            termux_uid_cache=2$termux_uid
            termux_uid_all=5$termux_uid
            # 1007=log, 3003=inet, 9997=everybody
            SUDO="su -g $termux_uid -G 1007 -G 3003 -G 9997 -G $termux_uid_cache -G $termux_uid_all -Z u:r:untrusted_app:s0:c127,c256,c512,c768 - $termux_uid -c"
        fi
    fi

    # First, build platform/pm agnostic list of missing packages.
    command -v make >/dev/null || add_missing make
    command -v patch >/dev/null || add_missing patch
    command -v stow >/dev/null || add_missing stow

    if [ -z "$_MSYS2_" ]; then
        for pkg in fzf tmux; do
            command -v "$pkg" >/dev/null || add_missing "$pkg"
        done
        command -v nvim >/dev/null || add_missing neovim
        command -v rg >/dev/null || add_missing ripgrep
    fi

    if ! command -v zsh >/dev/null; then
        add_missing zsh
        if [ "$_MSYS2_" ]; then
            log INFO install_missing_packages 'Using MSYS2. Default shell setting is pointless'
        else
            SET_ZSH=y
        fi
    fi

    # Now append platform/pm specific packages
    if [ "$_PKGMGR_" = pacman ]; then
        # Separate branch for MSYS to make native msystems easier to handle.
        if [ "$_MSYS2_" ]; then
            [ -f /clang64/bin/nvim ] || add_missing mingw-w64-clang-x86_64-neovim-qt

            if [ "$MSYSTEM" = MSYS ]; then
                :
            else
                # Common msystem packages
                [ -f "$_MSYSPREF_/bin/fzf" ] || add_missing "${_MSYSPKGPREF_}fzf"
                [ -f "$_MSYSPREF_/bin/gh" ] || add_missing "${_MSYSPKGPREF_}github-cli"
                [ -f "$_MSYSPREF_/bin/git" ] || add_missing "${_MSYSPKGPREF_}git"
                [ -f "$_MSYSPREF_/bin/rg" ] || add_missing "${_MSYSPKGPREF_}ripgrep"

                # Specific msystem packages
                case $MSYSTEM in
                    MINGW64)
                        if [ `pacman -Qsq '^mingw-w64-x86_64-toolchain$' | wc -l` -lt 13 ]; then
                            add_missing mingw-w64-x86_64-toolchain
                        fi
                        ;;
                    CLANG64)
                        if [ `pacman -Qsq '^mingw-w64-clang-x86_64-toolchain$' | wc -l` -lt 22 ]; then
                            add_missing mingw-w64-clang-x86_64-toolchain
                        fi
                        ;;
                esac
            fi
        fi

        # Install missing via pacman
        [ -n "$MISSING" ] && {
            $SUDO 'pacman -Syy'
            $SUDO "pacman -S --needed --noconfirm $MISSING"
        }
    elif [ "$_PKGMGR_" = apt ] || [ "$_PKGMGR_" = pkg ]; then
        dpkg -s build-essential >/dev/null 2>&1 || add_missing build-essential

        [ "$_TERMUX_" ] && {
            dpkg -s termux-services >/dev/null 2>&1 || add_missing termux-services
        }

        # Install missing via apt/pkg
        if [ -n "$MISSING" ]; then
            $SUDO "$_PKGMGR_ update"
            $SUDO "$_PKGMGR_ install -y $MISSING"
        fi
    elif [ "$_PKGMGR_" = apk ]; then
        apk info | grep -q build-base || add_missing build-base
        command -v bash >/dev/null || add_missing bash
        command -v chsh >/dev/null || add_missing shadow
        command -v dircolors >/dev/null || add_missing coreutils

        # Install missing via apk
        $SUDO 'apk update'
        $SUDO "apk add --no-interactive $MISSING"
    else
        log ERROR install_missing_packages "Unknown package manager \"$_PKGMGR_\". Unable to install dependencies"
        exit 1
    fi

    # Whether ZSH is a default shell
    if [ -z "$_MSYS2_" ] && [ -z "$SET_ZSH" ]; then
        if [ "$_TERMUX_" ]; then
            ! [ -L ~/.termux/shell ] && SET_ZSH=y || {
                readlink -f ~/.termux/shell | grep -q /usr/bin/zsh || SET_ZSH=y
            }
        elif [ -s /etc/passwd ]; then
            grep "^`id -un`:" /etc/passwd | cut -d: -f7 | grep -q zsh$ || SET_ZSH=y
        elif command -v getent >/dev/null; then
            getent passwd "`id -un`" | cut -d: -f7 | grep -q zsh$ || SET_ZSH=y
        else
            [ "${SHELL##/*}" = zsh ] || SET_ZSH=y
        fi
        # Base name of the current running shell.
        # However, ps options differ across implementation
        # which requires additional handling for cross-platform usage.
        #basename "`ps -p $$ -o comm=`"
    fi

    if [ -n "$SET_ZSH" ]; then
        if command -v zsh >/dev/null; then
            if command -v chsh >/dev/null; then
                log INFO install_missing_packages 'Changing current user shell to zsh...'
                if [ "$_TERMUX_" ]; then
                    chsh -s zsh
                else
                    if ! chsh -s /bin/zsh `id -un` >/dev/null 2>&1; then
                        log WARN install_missing_packages 'Could not change shell for the current user. Trying with %s...\n' "$SUDO"
                        $SUDO "chsh -s /bin/zsh `id -un`"
                    fi
                fi
            else
                log ERROR install_missing_packages 'Could not find chsh utility. Please, change shell to zsh manually'
            fi
        else
            log ERROR install_missing_packages 'Could not find zsh executable to set as default shell for the current user'
        fi
    fi

    exit 0
)

initialize_submodules() (
    __FUNC__=initialize_submodules
    [ -z "`git submodule`" ] && log DEBUG "$__FUNC__" 'No submodules under worktree: %s\n' "$_WT_" && exit
    [ "$NO_SUBMODULES" ] && log WARN "$__FUNC__" 'Skipping submodules due to NO_SUBMODULES env var' && exit

    log INFO "$__FUNC__" 'Submodules initialization...'
    git submodule update --init --depth 1 --recursive
)

initialize_omz_plugins() (
    __FUNC__=initialize_omz_plugins
    [ "$NO_SUBMODULES" ] && log WARN "$__FUNC__" 'Skipping omz plugins due to NO_SUBMODULES env var' && exit
    [ "$NO_PLUGINS" ] && log WARN "$__FUNC__" 'Skipping omz plugins due to NO_PLUGINS env var' && exit

    log INFO "$__FUNC__" 'Initializing oh-my-zsh plugins...'
    set -- zsh-completions zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting fzf-tab
    for plugin in "$@"; do
        case $plugin in
            fast-syntax-highlighting)
                plugin_url=https://github.com/zdharma-continuum/fast-syntax-highlighting.git;;
            fzf-tab)
                plugin_url=https://github.com/Aloxaf/fzf-tab.git;;
            zsh-autocomplete)
                plugin_url=https://github.com/marlonrichert/zsh-autocomplete.git;;
            zsh-autosuggestions)
                plugin_url=https://github.com/zsh-users/zsh-autosuggestions.git;;
            zsh-completions)
                plugin_url=https://github.com/zsh-users/zsh-completions.git;;
            zsh-syntax-highlighting)
                plugin_url=https://github.com/zsh-users/zsh-syntax-highlighting.git;;
            *) continue
        esac
        plugin_dir=stow_submodule/oh-my-zsh/.oh-my-zsh/custom/plugins/$plugin

        if [ -d "$plugin_dir" ]; then
            log INFO "$__FUNC__" "Already cloned $plugin"
            continue
        fi

        if ! mkdir -p "$plugin_dir" 2>/dev/null; then
            log WARN "$__FUNC__" "Unable to create directories up to $plugin_dir"
            exit 1
        fi

        log INFO "$__FUNC__" "Cloning $plugin..."
        git clone --depth 1 -- "$plugin_url" "$plugin_dir"
    done
)

check_dotfiles() {
    set -- "$DOTFILES" "$DOTFILES/stow"
    [ "$INCLUDE_SUBMODULES" = y ] && set -- "$@" "$DOTFILES/stow_submodule"
    for dir in "$@"; do
        [ -d "$dir" ] || {
            log ERROR check_dotfiles '%s is not a directory or does not exist!\n' "$dir"
            exit 1
        }
    done
    return 0
}

prepare_stow_packages() {
    # Stow everything we can find. Idk how to make it selectable.
    unset STOW_FOLDERS STOW_SUBMODULE_FOLDERS

    for folder in "$DOTFILES/stow/"*; do
        fbn=${folder##*/}
        # MSYS2 has bad times with tmux
        [ "$fbn" = tmux ] && [ "$_MSYS2_" ] && continue
        # kali provides special kex for WSL
        [ "$fbn" = kex ] && [ "$_WSL_" ] && [ "$_LINUX_DISTRO_" = kali ] && continue
        # exclude heavily linux stuff
        [ "$fbn" = i3 ] && [ -z "$_LINUX_DISTRO_" ] && continue
        [ -d "$folder" ] && if [ -z "$STOW_FOLDERS" ]; then
            STOW_FOLDERS=$folder
        else
            STOW_FOLDERS=$STOW_FOLDERS,$folder
        fi
    done

    if [ "$INCLUDE_SUBMODULES" = y ]; then
        for folder in "$DOTFILES/stow_submodule/"*; do
            [ -d "$folder" ] && if [ -z "$STOW_SUBMODULE_FOLDERS" ]; then
                STOW_SUBMODULE_FOLDERS=$folder
            else
                STOW_SUBMODULE_FOLDERS=$STOW_SUBMODULE_FOLDERS,$folder
            fi
        done
    fi

    return 0
}

# Resolves symlinks.
# https://www.geeksforgeeks.org/linux-unix/how-to-find-out-file-types-in-linux/
# https://www.linux.com/training-tutorials/file-types-linuxunix-explained-detail/
get_filetype() {
    if [ -z "$1" ]; then
        printf 'get_filetype: Empty filepath\n' >&2
        printf 'null string'
        return 1
    elif [ ! -e "$1" ]; then
        printf 'Non-existent filepath: %s\n' "$1" >&2
        printf 'non-existent file'
        return 1
    fi
    # -f, -d, -b, -c, -p, -l, -S
    # -D (Door file for RPC on Sun Solaris systems, not used anywhere else)
    case `LC_ALL=C ls -ld "$1"` in
        -*) printf 'regular file';;
        d*) printf 'directory';;
        b*) printf 'block device';;
        c*) printf 'character device';;
        p*) printf 'named pipe (FIFO)';;
        #l*) printf 'symbolic link';;
        s*) printf 'socket';;
        D*) printf 'door file';;
        *)
            printf 'get_filetype: Unknown filetype for %s\n' "$1" >&2
            return 1
    esac
    return 0
}

# Initial arg - stow folders, separated by ','
recursive_conflicts_detection() (
    [ $# = 0 ] && exit 0
    #printf %s "$*" | grep -q , && { #}
    case $* in
        *,*)
            __FUNC__=recursive_conflicts_detection
            __IFS_OLD=$IFS; IFS=,
            # Unquoted $* and $@ act similarly (or even identical)
            set -- $*
            IFS=$__IFS_OLD; unset __IFS_OLD
            for folder in "$@"; do
                # Special empty field case in msys2 zsh
                [ -z "$folder" ] && continue
                log INFO "$__FUNC__" 'Checking conflicts for %s\n' "$folder"
                recursive_conflicts_detection "$folder"
            done
            exit 0
    esac
    for item in "$1/"* "$1/".*; do
        [ -e "$item" ] || continue
        ibn=${item##*/}
        [ "$ibn" = . ] || [ "$ibn" = .. ] && continue
        log DEBUG "$__FUNC__" 'Now we are in %s\n' "$item"

        home_mirror=${item#*stow}
        home_mirror=${home_mirror#*/}
        home_mirror=${home_mirror#*/}
        if [ -z "$home_mirror" ]; then
            log ERROR "$__FUNC__" "Could not extract home mirror from \"$item\""
            exit 1
        fi
        home_mirror=~/$home_mirror

        log DEBUG "$__FUNC__" 'home_mirror: %s\n' "$home_mirror"
        # Can be used for readability or flexibility in the renaming process
        # (home item dir path, home item base name)
        #hidp=${home_mirror%/*}
        #hibn=${home_mirror##*/}
        case $item in
            */.config|*/.config/personal|*/.local|*/.local/bin)
                log INFO "$__FUNC__" 'Ignoring %s\n' "$item"
                recursive_conflicts_detection "$item";;
            *)
                log INFO "$__FUNC__" 'Processing %s\n' "$item"
                if [ -e "$home_mirror" ] && [ ! -h "$home_mirror" ]; then
                    log ERROR "$__FUNC__" 'Conflict found: "%s" is a %s! Suffixing it with %s\n' \
                        "$home_mirror" "`get_filetype "$home_mirror"`" "$timestamp"
                    mv "$home_mirror" "${home_mirror}_$timestamp"
                fi
        esac
    done

    exit 0
)

check_conflicts() {
    # Ensure that
    # ~/.config
    # ~/.config/personal
    # ~/.local
    # ~/.local/bin
    # are real directories.
    # ~/.gnupg was omitted due to broken pinentry in termux which makes gpg unusable.
    set -- ~/.config ~/.config/personal ~/.local ~/.local/bin
    for dir in "$@"; do
        [ -d "$dir" ] || mkdir -p "$dir"
        ! [ -d "$dir" ] && log ERROR check_conflicts '%s is not a directory!\n' "$dir" && exit 1
        #[ "${dir##*/}" = gpg ] && chmod 700 "$dir"
    done

    # Ensure to NOT have conflicts with exising dotfiles that are not symlinks.
    log INFO check_conflicts 'STOW_FOLDERS: %s\n' "$STOW_FOLDERS"
    [ "$INCLUDE_SUBMODULES" = y ] && log INFO check_conflicts 'STOW_SUBMODULE_FOLDERS: %s\n' "$STOW_SUBMODULE_FOLDERS"
    timestamp=`date +%s` recursive_conflicts_detection "$STOW_FOLDERS" "$STOW_SUBMODULE_FOLDERS" ,
}

perform_stow() (
    [ "$1" = -D ] && unstow_flag=-D || unstow_flag=
    # Set IFS to process comma-separated lists
    __IFS_OLD=$IFS; IFS=,
    set -- $STOW_FOLDERS $STOW_SUBMODULE_FOLDERS
    IFS=$__IFS_OLD; unset __IFS_OLD
    # Run stow for each package
    for folder in "$@"; do
        fdp=${folder%/*}
        fbn=${folder##*/}
        if [ "$unstow_flag" ]; then
            log INFO perform_stow 'Unstowing %s...\n' "$fbn"
        else
            log INFO perform_stow 'Stowing %s...\n' "$fbn"
        fi
        stow $unstow_flag -d "$fdp" -t ~ "$fbn"
    done
    return 0
)

perform_unstow() { perform_stow -D; }

# $1 - git ref and directory for worktree
# $2 - hint for OS, OS_ENV, or null otherwise
# $3 - ignore error if ref does not exist
propagate_bootstrap() {
    if [ "$3" ]; then
        set -- "$1" "$2" WARN
    else
        set -- "$1" "$2" ERROR
    fi
    set -- "$1" "$2" "propagate_bootstrap:$branch_ref:$script_path" "$3"
    if [ -z "$1" ]; then
        log ERROR "$3" 'No path to directory provided in $1'
        return 1
    fi
    if [ "$1" = master ]; then
        log ERROR "$3" 'Bootstrap cannot be propagated to master'
        return 1
    fi
    if ! prepare_worktree "$1"; then
        if [ "$2" ]; then
            log "$4" "$3" 'Not supported %s worktree: %s\n' "$2" "$1"
        else
            log "$4" "$3" 'Not supported worktree: %s\n' "$1"
        fi
        [ "$4" = WARN ] && return 0
        return 1
    fi
    if [ ! -d "$master_root" ]; then
        log ERROR "$3" 'Master root is not a directory or does not exist: %s\n' "$master_root"
        return 1
    fi
    printf %s "$master_root" >$1/.master_root
    if [ -e "$1/bootstrap.sh" ]; then
        "$1/bootstrap.sh"
    fi
}

# $1 - git ref and directory for worktree
# $2 - force flag (-f or --force)
propagate_debootstrap() {
    [ -d "$1" ] || return 0
    if [ "$2" ] && [ "$2" != -f ] && [ "$2" != --force ]; then
        set -- "$1" ""
    fi
    set -- "$1" "$2" "propagate_debootstrap:$branch_ref:$script_path"
    if [ -e "$1/debootstrap.sh" ]; then
        "$1/debootstrap.sh" $2 || return
    fi
    if [ "$2" ]; then
        :
    elif ! git submodule deinit --all; then
        log ERROR "$3" 'Submodules are dirty in worktree: %s\n' "$1"
        return 1
    elif ! is_clean_git_status "$1"; then
        log ERROR "$3" 'Worktree is dirty: %s\n' "$1"
        git -C "$1" status -s
        return 1
    fi
    git worktree remove -f "$1"
}

# $1 - path to directory with install.sh
propagate_install() {
    [ "${1%%/*}" ] && set -- "$PWD/$1"
    set -- "$1" "propagate_install:$branch_ref:$script_path"
    if [ -z "$1" ]; then
        log ERROR "$3" 'No path to directory provided in $1'
        return 1
    fi
    if [ ! -d "$1" ]; then
        log ERROR "$2" 'Worktree does not exist or not supported: %s\n' "$1"
        log ERROR "$2" 'Make sure to run master/bootstrap.sh first'
        return 1
    fi
    if [ -e "$1/install.sh" ]; then
        "$1/install.sh"
    fi
}

# $1 - path to directory with uninstall.sh
propagate_uninstall() {
    [ -d "$1" ] || return 0
    if [ -e "$1/uninstall.sh" ]; then
        "$1/uninstall.sh"
    fi
}


# Can't handle msys2 without a proper filepaths extraction
# from a given patch file to guard .exe files.
# $1 - path to patch file
# $2 - directory to cd into
# Return 0 if applied or was applied before, 1 if not applicable or an error occured.
#apply_patch() (
#    __FUNC__=apply_patch
#    [ -z "$1" ] && log ERROR "$__FUNC__" 'No patch file provided in $1' && return 1
#    [ ! -f "$1" ] && log ERROR "$__FUNC__" 'Invalid path to a patch file: %s\n' "$1" && return 1
#    if [ "$2" ]; then
#        [ ! -d "$2" ] && log ERROR "$__FUNC__" 'Invalid path to a directory to cd into: %s\n' "$2" && return 1
#    else
#        set -- "$1" "$PWD"
#    fi
#    pbn=${1##*/}
#    [ "$_MSYS2_" ] && out_files=`out_patch_files "$1" "$2"`
#    # ...
#)





# Left just for reference/examples.
#
# POSIX Issue 8 (2024) Draft for awk utility:
#https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html
#
# POSIX/GNU sed uses greedy match and does not support *?, here is a little hack with awk to acquire first stow occurence in case if path contains multiple
#home_mirror=~`echo "$item" | sed -E 's#.+/stow[^/]*/[^/]+##'`
#
# POSIX awk does not support adequate regexps in match(), so piping to sed in order to perform hacky reluctant regex match
#home_mirror="$HOME`echo "$item" | awk '
#/stow/ {
#    first_stow_idx = match($0, /stow/)
#    first_stow_substr = substr($0, first_stow_idx)
#    print first_stow_substr
#    next
#}' | sed 's#[^/]\+/[^/]*##'`"
#
# Pure awk.
#home_mirror=~/`printf %s "$item" | awk '
#{
#    # match implicitly sets RSTART (1-based index of match, 0 if no match)
#    # and RLENGTH (length of match, -1 if no match).
#    # substr range works inclusively for both sides.
#    base = substr($0, match($0, /\/stow[^/]*\/[^/]+\//))
#    if (RLENGTH!=-1) {
#        result = substr(base,RLENGTH+1)
#        if (result!="") print result
#    }
#}'`
#
# With more robust awk (gawk maybe?) it could look like (if *? is not supported)
# UPD. The version above uses implicit RSTART and RLENGTH I didn't know about before.
#home_mirror=~/`awk -v item="$item" '
#BEGIN {
#    first_stow_idx = match(item, /stow/)
#    first_stow_substr = substr(item, first_stow_idx)
#    final_match_idx = match(first_stow_substr, /[^/]+\/[^/]*/)
#    final_match_substr = substr(first_stow_substr, final_match_idx)
#    print final_suffix
#    next
#}'
#
# Or if *? is supported (can't confirm if it is a correct one regex, but it should be)
#home_mirror=~/`awk -v item="$item" '
#BEGIN {
#    final_match_idx = match(item, /.*?stow[^/]*\/[^/]*/)
#    final_match_substr = substr(item, final_match_idx)
#    print final_match_substr
#}'
