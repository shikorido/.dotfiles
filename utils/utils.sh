# DOTFILES management
# master
# utils.sh

[ "$_UTILS_H" = 1 ] && return 0
_UTILS_H=1
. "${master_root:-.}/utils/logger.sh"
. "${master_root:-.}/utils/git_utils.sh"

setup_variables() {
    [ -n "$VARIABLES_SETTED_UP" ] && return 0

    # Make sure the following variables are empty
    unset OS DEBIAN MSYS2 TERMUX WSL OS_ENV
    DEBIAN=0; MSYS2=0; TERMUX=0; WSL=0

    # General OS detection, will be tweaked to linux if MSYS2 is detected
    OS=`uname | tr '[:upper:]' '[:lower:]'`

    # Debian distro detection
    [ -s /etc/debian_version ] && DEBIAN=1

    # MSYS2 detection (any kind)
    uname | grep -q "MINGW64_NT\|MINGW32_NT\|MSYS_NT" && MSYS2=1

    # Termux detection (double check)
    [ -n "$TERMUX_VERSION" ] && TERMUX=1
    [ "$TERMUX" = 0 ] && [ -O /data/data/com.termux ] && TERMUX=1

    # WSL detection to exclude kex from installing
    uname -r | grep -q WSL && WSL=1

    # Sanity check
    if ! [ $(( DEBIAN + MSYS2 + TERMUX )) = 1 ]; then
        log ERROR setup_variables "Only one of DEBIAN, MSYS2 or TERMUX should be defined! Terminating..."
        unset OS DEBIAN MSYS2 TERMUX OS_ENV
        exit 1
    fi

    # Tweaking OS in case of MSYS2
    [ "$MSYS2" = 1 ] && OS=linux

    # Setting up the OS_ENV variable for a final worktree
    [ "$DEBIAN" = 1 ] && OS_ENV=kali
    [ -z "$OS_ENV" ] && [ "$MSYS2" = 1 ] && OS_ENV=msys2
    [ -z "$OS_ENV" ] && [ "$TERMUX" = 1 ] && OS_ENV=termux

    if [ -z "$PRINT_INFO" ]; then
        [ -f ~/.zsh_env_persistent ] && rm -f ~/.zsh_env_persistent
        log INFO setup_variables "Inferred environment variables:"
        for var in OS DEBIAN TERMUX MSYS2 WSL OS_ENV; do
            log INFO setup_variables "%6s: %s\n" "$var" "`eval printf %s '$'$var`"
            # Make variables persistent to source from dotfiles (can be defined with export ofc).
            printf "_%s_=%s\n" "$var" "`eval printf %s '$'$var`" >>~/.zsh_env_persistent
        done
        export PRINT_INFO=n
    fi

    export OS DEBIAN MSYS2 TERMUX WSL OS_ENV
    export VARIABLES_SETTED_UP=y

    return 0
}

install_missing_packages() (
    if [ "$MSYS2" = 1 ]; then
        [ `pacman -Qsq '^mingw-w64-x86_64-toolchain$' | wc -l` -lt 13 ] && MISSING=mingw-w64-x86_64-toolchain
        [ -f /clang64/bin/nvim ] || MISSING="$MISSING mingw-w64-clang-x86_64-neovim-qt"
        [ -f /usr/bin/stow ] || MISSING="$MISSING stow"
        [ -f /usr/bin/zsh ] || MISSING="$MISSING zsh"

        log INFO install_missing_packages "Using MSYS2. Default shell setting is pointless"

        [ -n "$MISSING" ] && {
            sh -c "pacman -Syy"
            sh -c "pacman -S --needed --noconfirm $MISSING"
        }
    else #DEBIAN,TERMUX
        dpkg -s build-essential >/dev/null 2>&1 || MISSING=build-essential
        #fzf
        for pkg in nvim stow tmux zsh; do
            ! command -v "$pkg" >/dev/null && {
                MISSING="$MISSING $pkg"
                [ "$pkg" = zsh ] && SET_ZSH=y
            }
        done

        [ "$TERMUX" = 1 ] && {
            dpkg -s termux-services >/dev/null 2>&1 || MISSING="$MISSING termux-services"
        }

        # Whether ZSH is a default shell
        [ -z "$SET_ZSH" ] && {
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
        }

        [ "$DEBIAN" = 1 ] && {
            # Determine which command will serve as SUDO
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
        }

        # Install missing packages
        [ -n "$MISSING" ] && {
            if [ "$DEBIAN" = 1 ]; then
                $SUDO "apt update"
                $SUDO "apt install $MISSING"
            elif [ "$TERMUX" = 1 ]; then
                pkg update
                sh -c "apt install -y $MISSING"
            else
                log ERROR install_missing_packages "Unknown environment (not DEBIAN, MSYS2, or TERMUX). Unable to install dependencies"
                exit 1
            fi
        }

        [ -n "$SET_ZSH" ] && {
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
                exit 1
            fi
        }
    fi

    exit 0
)

initialize_submodules() (
    __FUNC__=initialize_submodules
    [ -n "$NO_SUBMODULES" ] && log WARN "$__FUNC__" "Skipping submodules due to NO_SUBMODULES env var" && exit 0

    # Better solution is to write get_submodules git function which returns LF separated submodules.
    # Or simply use "git submodule update --quiet --init --depth 1 --recursive"
    set -- stow_submodule/fzf/.fzf stow_submodule/oh-my-zsh/.oh-my-zsh

    log INFO "$__FUNC__" "Submodules initialization..."
    for submodule_dir in "$@"; do
        # Initialize git submodule if submodule's directory is empty.
        if rmdir "$submodule_dir" 2>/dev/null; then
            submodule_name=${submodule_dir%/*}
            submodule_name=${submodule_name##*/}
            log INFO "$__FUNC__" "Cloning $submodule_name into $submodule_dir..."
            git submodule update --quiet --init --depth 1 --recursive "$submodule_dir"
        fi
    done

    # Installer will try to find existing fzf and download only if existing is not up-to-date
    # Need to come up with something...
    log INFO "$__FUNC__" "Installing or upgrading fzf..."
    stow_submodule/fzf/.fzf/install --bin

    exit 0
)

initialize_plugins() (
    __FUNC__=initialize_plugins
    [ -n "$NO_SUBMODULES" ] && log WARN "$__FUNC__" "Skipping plugins due to NO_SUBMODULES env var" && exit 0

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
        plugin_dir=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/$plugin
        [ -d "$plugin_dir" ] && continue
        # Fail silently.
        mkdir -p "$plugin_dir" || continue
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

    # Skipping hidden folders for .git repo support
    #for folder in "$DOTFILES/stow/"* "$DOTFILES/stow/".*; do
    #    [ -e "$folder" ] || continue
    #    fbn=${folder##*/}
    #    [ "$fbn" = . ] || [ "$fbn" = .. ] && continue
    for folder in "$DOTFILES/stow/"*; do
        # MSYS2 has bad times with tmux
        [ "$MSYS2" = 1 ] && [ "${folder##*/}" = tmux ] && continue
        # kali provides special kex for WSL
        # is there a better way to handle separate bin folders?
        [ "$WSL" = 0 ] && [ "${folder##*/}" = bin_wsl ] && continue
        [ "$WSL" = 1 ] && [ "${folder##*/}" = bin_general ] && continue
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

        home_mirror=~/`printf %s "$item" | awk '
        {
            # match implicitly sets RSTART (1-based index of match, 0 if no match)
            # and RLENGTH (length of match, -1 if no match).
            # substr range works inclusively for both sides.
            base = substr($0, match($0, /\/stow[^/]*\/[^/]+\//))
            if (RLENGTH!=-1) {
                result = substr(base,RLENGTH+1)
                if (result!="") print result
            }
        }'`
        #home_mirror="$HOME`echo "$item" | sed --posix -E 's#.+/stow[^/]*/[^/]+##'`"
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
            */.config|*/.local|*/.local/bin)
            #*/.gnupg|*/.config|*/.local|*/.local/bin)
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

check_conflicts() {
    # Ensure the ~/.config, ~/.local and ~/.local/bin are real directories.
    # ~/.gnupg was omitted due to broken pinentry in termux which makes gpg unusable.
    set -- ~/.config ~/.local ~/.local/bin
    for dir in "$@"; do
        [ -d "$dir" ] || mkdir -p "$dir"
        ! [ -d "$dir" ] && log ERROR check_conflicts "%s is not a directory!\n" "$dir" && exit 1
        #[ "${dir##*/}" = gpg ] && chmod 700 "$dir"
    done

    # Ensure to NOT have conflicts with exising dotfiles that are not symlinks.
    log INFO check_conflicts "STOW_FOLDERS: %s\n" "$STOW_FOLDERS"
    [ "$INCLUDE_SUBMODULES" = y ] && log INFO check_conflicts "STOW_SUBMODULE_FOLDERS: %s\n" "$STOW_SUBMODULE_FOLDERS"
    export timestamp=`date +%s`
    recursive_conflicts_detection "$STOW_FOLDERS" "$STOW_SUBMODULE_FOLDERS"
    unset timestamp

    return 0
}

perform_stow() {
    [ "$1" = unstow ] || [ "$1" = -D ] && set -- -D || set --
    # Set IFS to process comma-separated lists.
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

#check_conflicts() {
#    # Ensure the ~/.config, ~/.local and ~/.local/bin are real directories
#    [ -d ~/.config ] || mkdir -p ~/.config
#    [ -d ~/.local ] || mkdir -p ~/.local
#    [ -d ~/.local/bin ] || mkdir -p ~/.local/bin
#    ! [ -d ~/.config ] && echo "$HOME/.config is not a directory!" && exit 1
#    ! [ -d ~/.local ] && echo "$HOME/.local is not a directory!" && exit 1
#    ! [ -d ~/.local/bin ] && echo "$HOME/.local/bin is not a directory!" && exit 1
#
#    # Ensure to NOT have conflicts with exising dotfiles that are not symlinks
#    timestamp=$(date +%s)
#    __IFS_OLD=$IFS
#    IFS=,
#    echo "STOW_FOLDERS: $STOW_FOLDERS"
#    echo "STOW_SUBMODULE_FOLDERS: $STOW_SUBMODULE_FOLDERS"
#    for folder in $STOW_FOLDERS $STOW_SUBMODULE_FOLDERS; do
#        echo "Checking conflicts for $folder"
#        for item in "$folder/"* "$folder/".*; do
#            [ -e "$item" ] || continue
#            ibn=${item##*/}
#            [ "$ibn" = "." ] || [ "$ibn" = ".." ] && continue
#            #echo "Now it is $item"
#            if [ "$ibn" != .config ] && [ "$ibn" != .local ]; then
#                #echo "Processing $item (should not be .config nor .local folders)"
#                if ! [ -L "$HOME/$ibn" ]; then
#                    if [ -f "$item" ] && [ -e "$HOME/$ibn" ]; then
#                        echo "Conflict found: $HOME/$ibn is a file! Suffixing it with $timestamp"
#                        mv "$HOME/$ibn" "$HOME/${ibn}_$timestamp"
#                    elif [ -d "$item" ] && [ -e "$HOME/$ibn" ]; then
#                        echo "Conflict found: $HOME/$ibn is a folder! Suffixing it with $timestamp"
#                        mv "$HOME/$ibn" "$HOME/${ibn}_$timestamp"
#                    fi
#                fi
#                # Lets hope there are only folders and files please...
#            else
#                #echo "Processing $item (should be .config or .local folders)"
#                for item_inner in "$item/"* "$item/".*; do
#                    [ -e "$item_inner" ] || continue
#                    ibn_inner=${item_inner##*/}
#                    [ "$ibn_inner" = "." ] || [ "$ibn_inner" = ".." ] && continue
#                    [ "$ibn" = .local ] && [ "$ibn_inner" = bin ] && continue
#                    if ! [ -L "$HOME/$ibn/$ibn_inner" ]; then
#                        if [ -f "$item_inner" ] && [ -e "$HOME/$ibn/$ibn_inner" ]; then
#                            echo "Conflict found: $HOME/$ibn/$ibn_inner is a file! Suffixing it with $timestamp"
#                            mv "$HOME/$ibn/$ibn_inner" "$HOME/$ibn/${ibn_inner}_$timestamp"
#                        elif [ -d "$item_inner" ] && [ -e "$HOME/$ibn/$ibn_inner" ]; then
#                            echo "Conflict found: $HOME/$ibn/$ibn_inner is a folder! Suffixing it with $timestamp"
#                            mv "$HOME/$ibn/$ibn_inner" "$HOME/$ibn/${ibn_inner}_$timestamp"
#                        fi
#                    fi
#                    # Lets hope there are only folders and files please...
#                done
#            fi
#        done
#    done
#    IFS=$__IFS_OLD
#}

