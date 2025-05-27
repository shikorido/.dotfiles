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
# PACKAGEMGR - package manager str
setup_variables() {
    [ -n "$VARIABLES_SETTED_UP" ] && return 0

    # Make sure the following variables are empty
    unset ID LINUX MSYS2 TERMUX WSL OS OS_ENV LINUX_DISTRO PACKAGEMGR
    LINUX=0; MSYS2=0; TERMUX=0; WSL=0

    # General OS detection, will be tweaked to linux if MSYS2 is detected
    OS=`uname | tr '[:upper:]' '[:lower:]'`

    # MSYS2 detection (any kind)
    printf %s "$OS" | grep -q -i "MINGW64_NT\|MINGW32_NT\|MSYS_NT" && ID=msys2

    # Termux detection (double check)
    [ -z "$ID" ] && [ -n "$TERMUX_VERSION" ] && ID=termux
    [ -z "$ID" ] && [ -d /data/data/com.termux ] && ID=termux

    # Linux distro detection, msys2 also has this file
    [ -z "$ID" ] && [ -f /etc/os-release ] && . /etc/os-release

    case $ID in
        debian|kali|ubuntu)
            PACKAGEMGR=apt
            LINUX=1;;
        alpine)
            PACKAGEMGR=apk
            LINUX=1;;
        msys2)
            PACKAGEMGR=pacman
            MSYS2=1;;
        termux)
            PACKAGEMGR=pkg
            TERMUX=1;;
        *) # I have no experience with other PMs yet
            ;;
    esac

    [ "$LINUX" = 1 ] && LINUX_DISTRO=$ID

    # WSL detection to exclude kex from installing
    uname -r | grep -q WSL && WSL=1

    # Sanity check
    if ! [ $(( LINUX + MSYS2 + TERMUX )) = 1 ]; then
        log ERROR setup_variables "Only one of LINUX, MSYS2 or TERMUX should be defined! Terminating..."
        unset ID LINUX MSYS2 TERMUX OS OS_ENV LINUX_DISTRO PACKAGEMGR
        exit 1
    fi

    # Tweaking OS in case of MSYS2 and termux, they use the same linux worktree
    [ "$MSYS2" = 1 ] || [ "$TERMUX" ] && OS=linux

    # Setting up the OS_ENV variable for inner worktree
    OS_ENV=$ID

    if [ -z "$PRINT_INFO" ]; then
        [ -f ~/.zsh_env_persistent ] && rm -f ~/.zsh_env_persistent
        log INFO setup_variables "Inferred environment variables:"
        for var in LINUX TERMUX MSYS2 WSL OS OS_ENV LINUX_DISTRO PACKAGEMGR; do
            log INFO setup_variables "%12s: %s\n" "$var" "`eval printf %s '$'$var`"
            # Make variables persistent to source from dotfiles (can be defined with export ofc)
            printf "_%s_=%s\n" "$var" "`eval printf %s '$'$var`" >>~/.zsh_env_persistent
        done
        export PRINT_INFO=n
    fi

    unset ID
    export LINUX MSYS2 TERMUX WSL OS OS_ENV LINUX_DISTRO PACKAGEMGR
    export VARIABLES_SETTED_UP=y

    return 0
}

add_missing() {
    while [ $# -ne 0 ]; do
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
    if [ "$LINUX" = 1 ]; then
        if command -v sudo >/dev/null; then
            log INFO install_missing_packages "Using sudo as superuser cmd"
            SUDO="sudo sh -c"
        elif command -v su >/dev/null; then
            log WARN install_missing_packages "Unable to find sudo"
            log WARN install_missing_packages "Using su -c as superuser cmd"
            SUDO="su -c"
        else
            log ERROR install_missing_packages "Unable to find privilege escalation utility (sudo, su)"
            log ERROR install_missing_packages "Using \"sh -c\" may result in insufficient privileges"
            SUDO="sh -c"
        fi
    else
        SUDO="sh -c"
        # In termux, we can't run pkg under root,
        # so here is the right place for a command
        # that runs pkg under termux user.
        if [ "$TERMUX" = 1 ] && [ "`id -u`" = 0 ]; then
            termux_uid=`grep -F "com.termux " /data/system/packages.list | cut -d" " -f2`
            termux_uid_cache=2${termux_uid#?}
            termux_uid_all=5${termux_uid#?}
            # 1007=log, 3003=inet, 9997=everybody
            SUDO="su -g $termux_uid -G 1007 -G 3003 -G 9997 -G $termux_uid_cache -G $termux_uid_all -Z u:r:untrusted_app:s0:c127,c256,c512,c768 - $termux_uid -c"
        fi
    fi

    # First, build platform/pm agnostic list of missing packages.
    # MSYS2 is an exception, I don't want to mix win-native and msys2 tools.
    if ! [ "$MSYS2" = 1 ]; then
        for pkg in fzf stow tmux; do
            command -v $pkg >/dev/null || add_missing "$pkg"
        done
        command -v nvim >/dev/null || add_missing neovim
    fi

    if ! command -v zsh >/dev/null; then
        add_missing zsh
        if [ "$MSYS2" = 1 ]; then
            log INFO install_missing_packages "Using MSYS2. Default shell setting is pointless"
        else
            SET_ZSH=y
        fi
    fi

    # Now append platform/pm specific packages
    if [ "$PACKAGEMGR" = pacman ]; then
        if [ "$MSYS2" = 1 ]; then
            if [ `pacman -Qsq '^mingw-w64-x86_64-toolchain$' | wc -l` -lt 13 ]; then
                add_missing mingw-w64-x86_64-toolchain
            fi
            [ -f /mingw64/bin/fzf ] || add_missing mingw-w64-x86_64-fzf
            [ -f /clang64/bin/nvim ] || add_missing mingw-w64-clang-x86_64-neovim-qt
        fi

        # Install missing via pacman
        [ -n "$MISSING" ] && {
            $SUDO "pacman -Syy"
            $SUDO "pacman -S --needed --noconfirm $MISSING"
        }
    elif [ "$PACKAGEMGR" = apt ] || [ "$PACKAGEMGR" = pkg ]; then
        dpkg -s build-essential >/dev/null 2>&1 || add_missing build-essential

        [ "$TERMUX" = 1 ] && {
            dpkg -s termux-services >/dev/null 2>&1 || add_missing termux-services
        }

        # Install missing via apt/pkg
        if [ -n "$MISSING" ]; then
            $SUDO "$PACKAGEMGR update"
            $SUDO "$PACKAGEMGR install -y $MISSING"
        fi
    elif [ "$PACKAGEMGR" = apk ]; then
        apk info | grep -q build-base || add_missing build-base
        command -v chsh >/dev/null || add_missing shadow
        command -v dircolors >/dev/null || add_missing coreutils
        command -v bash >/dev/null || add_missing bash

        # Install missing via apk
        $SUDO "apk update"
        $SUDO "apk add --no-interactive $MISSING"
    else
        log ERROR install_missing_packages "Unknown package manager '$PACKAGEMGR'. Unable to install dependencies"
        exit 1
    fi

    # Whether ZSH is a default shell
    if ! [ "$MSYS2" = 1 ] && [ -z "$SET_ZSH" ]; then
        if [ "$TERMUX" = 1 ]; then
            ! [ -L ~/.termux/shell ] && SET_ZSH=y || {
                readlink -f ~/.termux/shell | grep -q "/usr/bin/zsh" || SET_ZSH=y
            }
        elif [ -s /etc/passwd ]; then
            grep "^`id -un`:" /etc/passwd | cut -d: -f7 | grep -q "zsh$" || SET_ZSH=y
        elif command -v getent >/dev/null; then
            getent passwd "`id -un`" | cut -d: -f7 | grep -q "zsh$" || SET_ZSH=y
        else
            [ "${SHELL##/*}" = "zsh" ] || SET_ZSH=y
        fi
        # Base name of the current running shell
        #basename "`ps -p $$ -o comm=`"
    fi

    if [ -n "$SET_ZSH" ]; then
        if command -v zsh >/dev/null; then
            if command -v chsh >/dev/null; then
                log INFO install_missing_packages "Changing current user shell to zsh..."
                if [ "$TERMUX" = 1 ]; then
                    chsh -s zsh
                else
                    if ! chsh -s /bin/zsh `id -un` >/dev/null 2>&1; then
                        log WARN install_missing_packages "Could not change shell for the current user. Trying with %s...\n" "$SUDO"
                        $SUDO "chsh -s /bin/zsh `id -un`"
                    fi
                fi
            else
                log ERROR install_missing_packages "Could not find chsh utility. Please, change shell to zsh manually"
            fi
        else
            log ERROR install_missing_packages "Could not find zsh executable to set as default shell for the current user"
        fi
    fi

    exit 0
)

initialize_submodules() (
    __FUNC__=initialize_submodules
    [ -n "$NO_SUBMODULES" ] && log WARN "$__FUNC__" "Skipping submodules due to NO_SUBMODULES env var" && exit 0

    # Better solution is to write get_submodules git function which returns LF separated submodules.
    # Or simply use "git submodule update --quiet --init --depth 1 --recursive"
    set -- stow_submodule/oh-my-zsh/.oh-my-zsh

    log INFO "$__FUNC__" "Submodules initialization..."
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
    [ -n "$NO_SUBMODULES" ] && log WARN "$__FUNC__" "Skipping plugins due to NO_SUBMODULES env var" && exit 0
    [ -n "$NO_PLUGINS" ] && log WARN "$__FUNC__" "Skipping plugins due to NO_PLUGINS env var" && exit 0

    log INFO "$__FUNC__" "Plugins initialization..."

    # Initialize oh-my-zsh plugins
    log INFO "$__FUNC__" "Initializing oh-my-zsh plugins..."
    set -- zsh-completions zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting fzf-tab
    for plugin in "$@"; do
        case $plugin in
            fast-syntax-highlighting)
                plugin_url=https://github.com/zdharma-continuum/fast-syntax-highlighting.git ;;
            fzf-tab)
                plugin_url=https://github.com/Aloxaf/fzf-tab.git ;;
            zsh-autocomplete)
                plugin_url=https://github.com/marlonrichert/zsh-autocomplete.git ;;
            zsh-autosuggestions)
                plugin_url=https://github.com/zsh-users/zsh-autosuggestions.git ;;
            zsh-completions)
                plugin_url=https://github.com/zsh-users/zsh-completions.git ;;
            zsh-syntax-highlighting)
                plugin_url=https://github.com/zsh-users/zsh-syntax-highlighting.git ;;
            *) continue ;;
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
            log ERROR check_dotfiles "%s is not a directory or does not exist!\n" "$dir"
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
        [ "$MSYS2" = 1 ] && [ "$fbn" = tmux ] && continue
        # kali provides special kex for WSL
        [ "$fbn" = kex ] && [ "$LINUX_DISTRO" = kali ] && [ "$WSL" = 1 ] && continue
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
    [ $# -eq 0 ] && exit 0
    printf %s "$*" | grep -q , && {
        export __FUNC__=recursive_conflicts_detection
        __IFS_OLD=$IFS; IFS=,
        # Unquoted $* and $@ act similarly (or even identical)
        for folder in $*; do
            # Special case in msys2 zsh
            [ -z "$folder" ] && continue
            IFS=$__IFS_OLD log INFO "$__FUNC__" "Checking conflicts for %s\n" "$folder"
            recursive_conflicts_detection "$folder"
        done
        IFS=$__IFS_OLD; __IFS_OLD=
        exit 0
    }
    for item in "$1/"* "$1/".*; do
        [ -e "$item" ] || continue
        ibn=${item##*/}
        [ "$ibn" = . ] || [ "$ibn" = .. ] && continue
        log DEBUG "$__FUNC__" "Now we are in %s\n" "$item"

        home_mirror="$HOME`echo "$item" | sed -E 's#.+/stow[^/]*/[^/]+##'`"
        if [ $? -ne 0 ]; then
            log ERROR "$__FUNC__" "Could not extract home mirror. Perhaps, sed -E is not supported?"
            exit 1
        fi
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
        # POSIX/GNU sed uses greedy match and does not accept *? at all, here is a little hack with awk to aquire first stow occurence in case if path contains several
        # POSIX awk does not support adequate regexps in match(), so piping to sed in order to perform hacky reluctant regex match
        #home_mirror="$HOME`echo "$item" | awk '
        #/stow/ {
        #    first_stow_idx = match($0, /stow/)
        #    first_stow_substr = substr($0, first_stow_idx)
        #    print first_stow_substr
        #    next
        #}' | sed 's#[^/]\+/[^/]*##'`"
        # With more robust awk (gawk maybe?) it could look like (if *? is not supported)
        #echo "$item" | awk '
        #/stow/ {
        #    first_stow_idx = match($0, /stow/)
        #    first_stow_substr = substr($0, first_stow_idx)
        #    final_match_idx = match(first_stow_substr, /[^/]+\/[^/]*/)
        #    final_match_substr = substr(first_stow_substr, final_match_idx)
        #    print final_suffix
        #    next
        #}'
        # Or if *? is supported (can't confirm if it is a correct one regex)
        #echo "$item" | awk '
        #/stow/ {
        #    final_match_idx = match($0, /.*?stow[^/]*\/[^/]*/)
        #    final_match_substr = substr($0, final_match_idx)
        #    print final_match_substr
        #    next
        #}'

        log DEBUG "$__FUNC__" "home_mirror: %s\n" "$home_mirror"
        # Can be used for readability or flexibility in the renaming process (home item dir path, home item base name respectively)
        #hidp=${home_mirror%/*}
        #hibn=${home_mirror##*/}
        case $item in
            */.config|*/.config/personal|*/.local|*/.local/bin)
                log INFO "$__FUNC__" "Ignoring %s\n" "$item"
                recursive_conflicts_detection "$item"
                ;;
            *)
            log INFO "$__FUNC__" "Processing %s\n" "$item"
            if [ -e "$home_mirror" ] && ! [ -L "$home_mirror" ]; then
                if [ -f "$item" ]; then
                    log ERROR "$__FUNC__" "Conflict found: \"%s\" is a file! Suffixing it with %s\n" "$home_mirror" "$timestamp"
                    mv "$home_mirror" "${home_mirror}_$timestamp"
                elif [ -d "$item" ]; then
                    log ERROR "$__FUNC__" "Conflict found: \"%s\" is a folder! Suffixing it with %s\n" "$home_mirror" "$timestamp"
                    mv "$home_mirror" "${home_mirror}_$timestamp"
                fi
            fi
            ;;
        esac
    done

    exit 0
)

check_conflicts() (
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
        ! [ -d "$dir" ] && log ERROR check_conflicts "%s is not a directory!\n" "$dir" && exit 1
        #[ "${dir##*/}" = gpg ] && chmod 700 "$dir"
    done

    # Ensure to NOT have conflicts with exising dotfiles that are not symlinks.
    log INFO check_conflicts "STOW_FOLDERS: %s\n" "$STOW_FOLDERS"
    [ "$INCLUDE_SUBMODULES" = y ] && log INFO check_conflicts "STOW_SUBMODULE_FOLDERS: %s\n" "$STOW_SUBMODULE_FOLDERS"
    export timestamp=`date +%s`
    recursive_conflicts_detection "$STOW_FOLDERS" "$STOW_SUBMODULE_FOLDERS" ,
    exit
)

perform_stow() {
    [ "$1" = unstow ] || [ "$1" = -D ] && set -- -D || set --
    # Set IFS to process comma-separated lists
    __IFS_OLD=$IFS; IFS=,
    # Run stow for each package
    for folder in $STOW_FOLDERS $STOW_SUBMODULE_FOLDERS; do
        fdp=${folder%/*}
        fbn=${folder##*/}
        if [ "$1" = -D ]; then
            log INFO perform_stow "Unstowing %s...\n" "$fbn"
        else
            log INFO perform_stow "Stowing %s...\n" "$fbn"
        fi
        stow $1 -d "$fdp" -t ~ "$fbn"
    done
    IFS=$__IFS_OLD; unset __IFS_OLD
    return 0
}
perform_unstow() {
    perform_stow -D
}
