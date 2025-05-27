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
    unset ID LINUX MSYS2 TERMUX WSL OS OS_ENV LINUX_DISTRO PKGMGR

    # General OS detection, will be tweaked to linux if MSYS2 is detected
    OS=`uname | tr '[:upper:]' '[:lower:]'`

    # MSYS2 detection (any kind)
    #printf %s "$OS" | grep -q -i 'MINGW64_NT\|MINGW32_NT\|MSYS_NT' && ID=msys2
    case $OS in *mingw*|*msys*) ID=msys2; esac

    # Termux detection (double check)
    [ -z "$ID" ] && [ "$TERMUX_VERSION" ] && ID=termux
    [ -z "$ID" ] && [ -d /data/data/com.termux ] && ID=termux

    # Linux distro detection, msys2 also has this file
    [ -z "$ID" ] && [ -f /etc/os-release ] && . /etc/os-release

    case $ID in
        debian|kali|ubuntu)
            PKGMGR=apt
            LINUX=1;;
        alpine)
            PKGMGR=apk
            LINUX=1;;
        msys2)
            PKGMGR=pacman
            MSYS2=1;;
        termux)
            PKGMGR=pkg
            TERMUX=1;;
        *) # I have no experience with other PMs yet
            ;;
    esac

    if [ "$MSYS2" ]; then
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
                # In this case, /etc/msystem.d/MSYS should be sourced.
                log ERROR setup_variables "Unknown MSYSTEM ($MSYSTEM)! Ensure MSYSTEM is correct before dotfiles installation"
                exit 1;;
            *)
                # Impossible unless explicitly unset or /etc/msystem was skipped.
                log ERROR setup_variables 'MSYSTEM is unset or null! Ensure MSYSTEM is correct before dotfiles installation'
                exit 1;;
        esac
        determine_git_flavor
    fi

    [ "$LINUX" ] && LINUX_DISTRO=$ID

    # WSL detection to exclude kex from installing
    #uname -r | grep -q WSL && WSL=1
    case `uname -r` in *WSL*) WSL=1; esac

    # Sanity check
    if [ $(( ${LINUX:-0} + ${MSYS2:-0} + ${TERMUX:-0} )) != 1 ]; then
        log ERROR setup_variables "Only one of LINUX (${LINUX:-null}), MSYS2 (${MSYS2:-null}), or TERMUX (${TERMUX:-null}) must be defined! Terminating..."
        unset ID LINUX MSYS2 TERMUX WSL OS OS_ENV LINUX_DISTRO PKGMGR
        exit 1
    fi

    # Tweaking OS in case of MSYS2 and termux, they both use linux worktree.
    # Although, linux worktree will always be used since sh files are executing.
    [ "$MSYS2" ] || [ "$TERMUX" ] && OS=linux

    # Setting up the OS_ENV variable for inner worktree
    OS_ENV=$ID

    if [ -z "$PRINT_INFO" ]; then
        [ -f ~/.zsh_env_persistent ] && rm -f ~/.zsh_env_persistent
        log INFO setup_variables 'Inferred environment variables:'
        for var in LINUX MSYS2 TERMUX WSL OS OS_ENV LINUX_DISTRO PKGMGR; do
            log INFO setup_variables '%12s: %s\n' "$var" "`eval printf %s '"$'$var'"'`"
            # Make variables persistent to source from dotfiles
            # Should they be exported? I guess, not really, but why not?
            printf 'export _%s_=%s\n' "$var" "`eval printf %s '"$'$var'"'`" >>~/.zsh_env_persistent
        done
        export PRINT_INFO=n
    fi

    unset ID
    export LINUX MSYS2 TERMUX WSL OS OS_ENV LINUX_DISTRO PKGMGR
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
    if [ "$LINUX" ]; then
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
        if [ "$TERMUX" ] && [ "`id -u`" = 0 ]; then
            termux_uid=`grep -F 'com.termux ' /data/system/packages.list | cut -d' ' -f2`
            case $termux_uid in
                # Normally, history expansion should disabled in scripts,
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
    # MSYS2 is an exception, I don't want to mix win-native and msys2 tools.
    command -v stow >/dev/null || add_missing stow
    if [ -z "$MSYS2" ]; then
        for pkg in fzf tmux; do
            command -v $pkg >/dev/null || add_missing $pkg
        done
        command -v nvim >/dev/null || add_missing neovim
    fi

    if ! command -v zsh >/dev/null; then
        add_missing zsh
        if [ "$MSYS2" ]; then
            log INFO install_missing_packages 'Using MSYS2. Default shell setting is pointless'
        else
            SET_ZSH=y
        fi
    fi

    # Now append platform/pm specific packages
    if [ "$PKGMGR" = pacman ]; then
        # Separate branch for MSYS to make native msystems easier to handle.
        if [ "$MSYS2" ] && [ "$MSYSTEM" = MSYS ]; then
            [ -f /clang64/bin/nvim ] || add_missing mingw-w64-clang-x86_64-neovim-qt

        elif [ "$MSYS2" ]; then
            [ -f /clang64/bin/nvim ] || add_missing mingw-w64-clang-x86_64-neovim-qt

            # Common msystem packages
            _mlower=`printf %s "$MSYSTEM" | tr '[:upper:]' '[:lower:]'`
            _mpref=${_mlower%??}-
            case $MSYSTEM in
                CLANGARM64)
                    _mpref=clang-
                    _march=aarch64;;
                MINGW64)
                    _mpref=
                    _march=x86_64;;
                MINGW32)
                    _mpref=
                    _march=i686;;
                *64)
                    _march=x86_64;;
                *32)
                    _march=i686;;
            esac

            [ -f /$_mlower/bin/fzf ] || add_missing mingw-w64-$_mpref$_march-fzf
            [ -f /$_mlower/bin/gh ] || add_missing mingw-w64-$_mpref$_march-github-cli
            [ -f /$_mlower/bin/git ] || add_missing mingw-w64-$_mpref$_march-git

            # Specific msystem packages
            case $MSYSTEM in
                MINGW64)
                    if [ `pacman -Qsq '^mingw-w64-x86_64-toolchain$' | wc -l` -lt 13 ]; then
                        add_missing mingw-w64-x86_64-toolchain
                    fi;;
                CLANG64)
                    if [ `pacman -Qsq '^mingw-w64-clang-x86_64-toolchain$' | wc -l` -lt 22 ]; then
                        add_missing mingw-w64-clang-x86_64-toolchain
                    fi;;
            esac
        fi

        # Install missing via pacman
        [ -n "$MISSING" ] && {
            $SUDO 'pacman -Syy'
            $SUDO "pacman -S --needed --noconfirm $MISSING"
        }
    elif [ "$PKGMGR" = apt ] || [ "$PKGMGR" = pkg ]; then
        dpkg -s build-essential >/dev/null 2>&1 || add_missing build-essential

        [ "$TERMUX" ] && {
            dpkg -s termux-services >/dev/null 2>&1 || add_missing termux-services
        }

        # Install missing via apt/pkg
        if [ -n "$MISSING" ]; then
            $SUDO "$PKGMGR update"
            $SUDO "$PKGMGR install -y $MISSING"
        fi
    elif [ "$PKGMGR" = apk ]; then
        apk info | grep -q build-base || add_missing build-base
        command -v bash >/dev/null || add_missing bash
        command -v chsh >/dev/null || add_missing shadow
        command -v dircolors >/dev/null || add_missing coreutils

        # Install missing via apk
        $SUDO 'apk update'
        $SUDO "apk add --no-interactive $MISSING"
    else
        log ERROR install_missing_packages "Unknown package manager \"$PKGMGR\". Unable to install dependencies"
        exit 1
    fi

    # Whether ZSH is a default shell
    if [ -z "$MSYS2" ] && [ -z "$SET_ZSH" ]; then
        if [ "$TERMUX" ]; then
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
        # Base name of the current running shell
        #basename "`ps -p $$ -o comm=`"
    fi

    if [ -n "$SET_ZSH" ]; then
        if command -v zsh >/dev/null; then
            if command -v chsh >/dev/null; then
                log INFO install_missing_packages 'Changing current user shell to zsh...'
                if [ "$TERMUX" ]; then
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
    [ -n "$NO_SUBMODULES" ] && log WARN "$__FUNC__" 'Skipping submodules due to NO_SUBMODULES env var' && exit 0

    # Better solution is to write get_submodules git function which returns LF separated submodules.
    # Or simply use "git submodule update --quiet --init --depth 1 --recursive"
    set -- stow_submodule/oh-my-zsh/.oh-my-zsh

    log INFO "$__FUNC__" 'Submodules initialization...'
    for submodule_dir in "$@"; do
        # Initialize git submodule if submodule's directory is empty
        if rmdir "$submodule_dir" 2>/dev/null; then
            submodule_name=${submodule_dir%/*}
            submodule_name=${submodule_name##*/}
            log INFO "$__FUNC__" "Cloning $submodule_name into $submodule_dir..."
            git submodule update --quiet --init --depth 1 --recursive "$submodule_dir"
        fi
    done

    exit 0
)

initialize_plugins() (
    __FUNC__=initialize_plugins
    [ -n "$NO_SUBMODULES" ] && log WARN "$__FUNC__" 'Skipping plugins due to NO_SUBMODULES env var' && exit 0
    [ -n "$NO_PLUGINS" ] && log WARN "$__FUNC__" 'Skipping plugins due to NO_PLUGINS env var' && exit 0

    log INFO "$__FUNC__" 'Plugins initialization...'

    # Initialize oh-my-zsh plugins
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
            continue
        fi

        log INFO "$__FUNC__" "Cloning $plugin..."
        git clone --depth 1 -- "$plugin_url" "$plugin_dir"
    done

    exit 0
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
        [ "$fbn" = tmux ] && [ "$MSYS2" ] && continue
        # kali provides special kex for WSL
        [ "$fbn" = kex ] && [ "$WSL" ] && [ "$LINUX_DISTRO" = kali ] && continue
        # exclude heavily linux stuff
        [ "$fbn" = i3 ] && [ -z "$LINUX_DISTRO" ] && continue
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
                if [ -e "$home_mirror" ] && ! [ -L "$home_mirror" ]; then
                    if [ -f "$item" ]; then
                        log ERROR "$__FUNC__" 'Conflict found: "%s" is a file! Suffixing it with %s\n' "$home_mirror" "$timestamp"
                        mv "$home_mirror" "${home_mirror}_$timestamp"
                    elif [ -d "$item" ]; then
                        log ERROR "$__FUNC__" 'Conflict found: "%s" is a folder! Suffixing it with %s\n' "$home_mirror" "$timestamp"
                        mv "$home_mirror" "${home_mirror}_$timestamp"
                    fi
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
    unset unstow_flag
    [ "$1" = unstow ] || [ "$1" = -D ] && unstow_flag=-D
    # Set IFS to process comma-separated lists
    __IFS_OLD=$IFS; IFS=,
    set -- $STOW_FOLDERS $STOW_SUBMODULE_FOLDERS
    IFS=$__IFS_OLD; unset __IFS_OLD
    # Run stow for each package
    for folder in "$@"; do
        fdp=${folder%/*}
        fbn=${folder##*/}
        if [ "$1" = -D ]; then
            log INFO perform_stow 'Unstowing %s...\n' "$fbn"
        else
            log INFO perform_stow 'Stowing %s...\n' "$fbn"
        fi
        stow $unstow_flag -d "$fdp" -t ~ "$fbn"
    done
    return 0
)

perform_unstow() { perform_stow -D; }





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
