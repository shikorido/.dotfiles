# DOTFILES management
# master
# utils.sh

export ESC="\033"
export RESET="${ESC}[0m"

# Regular Colors
export BLACK="${ESC}[38;5;0m"
export RED="${ESC}[38;5;1m"
export GREEN="${ESC}[38;5;2m"
export YELLOW="${ESC}[38;5;3m"
export BLUE="${ESC}[38;5;4m"
export MAGENTA="${ESC}[38;5;5m"
export CYAN="${ESC}[38;5;6m"
export WHITE="${ESC}[38;5;7m"

# Bright Colors
export BRIGHT_BLACK="${ESC}[38;5;8m"
export BRIGHT_RED="${ESC}[38;5;9m"
export BRIGHT_GREEN="${ESC}[38;5;10m"
export BRIGHT_YELLOW="${ESC}[38;5;11m"
export BRIGHT_BLUE="${ESC}[38;5;12m"
export BRIGHT_MAGENTA="${ESC}[38;5;13m"
export BRIGHT_CYAN="${ESC}[38;5;14m"
export BRIGHT_WHITE="${ESC}[38;5;15m"

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
        echo "setup_variables(): Only one of DEBIAN, MSYS2, or TERMUX should be defined! Terminate."
        unset OS DEBIAN MSYS2 TERMUX OS_ENV
        exit 1
    fi

    # Tweaking OS in case of MSYS2
    [ -n "$MSYS2" ] && OS=linux

    # Setting up the OS_ENV variable for a final worktree
    [ "$DEBIAN" = 1 ] && OS_ENV=kali
    [ -z "$OS_ENV" ] && [ "$MSYS2" = 1 ] && OS_ENV=msys2
    [ -z "$OS_ENV" ] && [ "$TERMUX" = 1 ] && OS_ENV=termux

    if [ -z "$PRINT_INFO" ]; then
        echo "Inferred environment variables:"
        printf "OS:\t%s\n" "$OS"
        printf "DEBIAN:\t%s\n" "$DEBIAN"
        printf "TERMUX:\t%s\n" "$TERMUX"
        printf "MSYS2:\t%s\n" "$MSYS2"
        printf "WSL:\t%s\n" "$WSL"
        printf "OS_ENV:\t%s\n" "$OS_ENV"
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

        echo "Using MSYS2. Default shell setting is pointless."

        [ -n "$MISSING" ] && {
            sh -c "pacman -Syy"
            sh -c "pacman -S --needed --noconfirm $MISSING"
        }
    else #DEBIAN,TERMUX
        dpkg -s build-essential >/dev/null 2>&1 || MISSING=build-essential
        #! command -v fzf >/dev/null && MISSING="$MISSING fzf"
        ! command -v nvim >/dev/null && MISSING="$MISSING neovim"
        ! command -v stow >/dev/null && MISSING="$MISSING stow"
        ! command -v tmux >/dev/null && MISSING="$MISSING tmux"
        ! command -v zsh >/dev/null && MISSING="$MISSING zsh" && SET_ZSH=y

        [ "$TERMUX" = 1 ] && {
            dpkg -s termux-services >/dev/null 2>&1 || MISSING=termux-services
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

        # Install missing packages
        [ -n "$MISSING" ] && {
            if [ "$DEBIAN" = 1 ]; then
                # Determine which command will serve as SUDO
                if command -v sudo >/dev/null; then
                    echo "Using sudo as superuser cmd"
                    SUDO="sudo sh -c"
                else
                    echo "sudo was not found."
                    echo "Using su -c as superuser cmd"
                    SUDO="su -c"
                fi
                $SUDO "apt update"
                $SUDO "apt install $MISSING"
            elif [ "$TERMUX" = 1 ]; then
                pkg update
                sh -c "apt install -y $MISSING"
            else
                echo "install_missing_packages(): Unknown environment (not DEBIAN, MSYS2, or TERMUX). Could not install dependencies."
                exit 1
            fi
        }

        [ -n "$SET_ZSH" ] && {
            if command -v zsh >/dev/null; then
                if command -v chsh >/dev/null; then
                    echo "Changing current user shell to zsh..."
                    if [ "$TERMUX" = 1 ]; then
                        chsh -s zsh
                    else
                        $SUDO "chsh -s /bin/zsh `id -un`"
                    fi
                else
                    echo "install_missing_packages(): Could not find chsh utility. Please, change shell to zsh manually."
                fi
            else
                echo "install_missing_packages(): Could not find zsh executable to set as default shell for the current user."
                exit 1
            fi
        }
    fi

    exit 0
)

initialize_submodules() (
    [ -n "$NO_SUBMODULES" ] && echo "initialize_submodules(): Skipping submodules due to NO_SUBMODULES env var." && exit 0

    echo "Submodules initialization..."

    # Initialize git submodules
    rmdir stow_submodule/fzf/.fzf 2>/dev/null && git submodule update --quiet --init --depth 1 --recursive stow_submodule/fzf/.fzf
    rmdir stow_submodule/oh-my-zsh/.oh-my-zsh 2>/dev/null && git submodule update --quiet --init --depth 1 --recursive stow_submodule/oh-my-zsh/.oh-my-zsh

    # Installer will try to find existing fzf and download only if existent one is not up-to-date
    # Need to come up with something...
    stow_submodule/fzf/.fzf/install --bin
    #stow_submodule/fzf/.fzf/install --bin >/dev/null 2>&1

    exit 0
)

check_dotfiles() {
    [ -d "$DOTFILES" ] || {
        echo "check_dotfiles(): $DOTFILES is not a directory or does not exist!"
        exit 1
    }

    [ -d "$DOTFILES/stow" ] || {
        echo "check_dotfiles(): $DOTFILES/stow is not a directory or does not exist!"
        exit 1
    }

    [ "$INCLUDE_SUBMODULES" = y ] && ! [ -d "$DOTFILES/stow_submodule" ] && {
        echo "check_dotfiles(): $DOTFILES/stow_submodule is not a directory or does not exist!"
        exit 1
    }

    return 0
}

prepare_stow_packages() {
    # Define comma-separated packages to stow if not defined yet
    if [ -z "$STOW_FOLDERS" ]; then
        STOW_FOLDERS=""
        # Skipping the hidden folders for .git repo support
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
    fi
    if [ "$INCLUDE_SUBMODULES" = y ] && [ -z "$STOW_SUBMODULE_FOLDERS" ]; then
        STOW_SUBMODULE_FOLDERS=""
        # Skipping the hidden folders for .git repo support
        #for folder in "$DOTFILES/stow_submodule/"* "$DOTFILES/stow_submodule/".*; do
        #    [ -e "$folder" ] || continue
        #    fbn=${folder##*/}
        #    [ "$fbn" = "." ] || [ "$fbn" = ".." ] && continue
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
    echo "$*" | grep -q , && {
        __IFS_OLD=$IFS; IFS=,
        # $* and $@ act similarly (or even identical)
        for folder in $*; do
            printf "${YELLOW}Checking conflicts for %s${RESET}\n" "$folder"
            recursive_conflicts_detection "$folder"
        done
        IFS=$__IFS_OLD; __IFS_OLD=
        exit 0
    }
    for item in "$1/"* "$1/".*; do
        [ -e "$item" ] || continue
        ibn=${item##*/}
        [ "$ibn" = . ] || [ "$ibn" = .. ] && continue
        printf "${YELLOW}Now we are in %s${RESET}\n" "$item"

        #home_mirror="$HOME`echo "$item" | sed --posix -E 's#.+/stow([^/]+)?/[^/]+##'`"
        # POSIX/GNU sed uses greedy match and does not accept *? at all, here is a little hack with awk to aquire first stow occurence in case if path contains several
        # POSIX awk does not support adequate regexps in match(), so piping to sed in order to perform hacky reluctant regex match
        home_mirror="$HOME`echo "$item" | awk '/stow/ { first_stow_idx = match($0, /stow/); first_stow_substr = substr($0, first_stow_idx); print first_stow_substr; next; }' | sed -E 's#[^/]+/[^/]*##'`"

        # With more robust awk (gawk maybe?) it could look like (if *? is not supported)
        #echo "$item" | awk '/stow/ { first_stow_idx = match($0, /stow/); first_stow_substr = substr($0, first_stow_idx); final_match_idx = match(first_stow_substr, /[^/]+\/[^/]*/); final_match_substr = substr(first_stow_substr, final_match_idx); print final_suffix; next; }'
        # Or if *? is supported (can't confirm if it is a correct one regex)
        #echo "$item" | awg '/stow/ { final_match_idx = match($0, /.*stow((\/)|([^/]+/))[^/]*/); final_match_substr = substr($0, final_match_idx); print final_match_substr; next; }'

        printf "${MAGENTA}home_mirror: \"%s\"${RESET}\n" "$home_mirror"
        # Can be used for readability or flexibility in the renaming process (home item dir path, home item base name respectively)
        #hidp=${home_mirror%/*}
        #hibn=${home_mirror##*/}
        case $item in
            */.config|*/.local|*/.local/bin)
            #*/.gnupg|*/.config|*/.local|*/.local/bin)
                printf "${GREEN}Ignoring %s${RESET}\n" "$item"
                recursive_conflicts_detection "$item"
                ;;
            *)
            printf "${CYAN}Processing %s${RESET}\n" "$item"
            if [ -e "$home_mirror" ] && ! [ -L "$home_mirror" ]; then
                if [ -f "$item" ]; then
                    printf "${RED}Conflict found: \"%s\" is a file! Suffixing it with %s${RESET}\n" "$home_mirror" "$timestamp"
                    mv "$home_mirror" "${home_mirror}_$timestamp"
                elif [ -d "$item" ]; then
                    printf "${RED}Conflict found: \"%s\" is a folder! Suffixing it with %s${RESET}\n" "$home_mirror" "$timestamp"
                    mv "$home_mirror" "${home_mirror}_$timestamp"
                fi
            fi
            ;;
        esac
    done

    exit 0
)

check_conflicts() {
    # Ensure the ~/.config, ~/.local and ~/.local/bin are real directories
    #[ -d ~/.gnupg ] || mkdir -p ~/.gnupg
    [ -d ~/.config ] || mkdir -p ~/.config
    [ -d ~/.local ] || mkdir -p ~/.local
    [ -d ~/.local/bin ] || mkdir -p ~/.local/bin
    #! [ -d ~/.gnupg ] && echo "check_conflicts(): $HOME/.gnupg is not a directory!" && exit 1 || chmod 700 ~/.gnupg
    ! [ -d ~/.config ] && echo "check_conflicts(): $HOME/.config is not a directory!" && exit 1
    ! [ -d ~/.local ] && echo "check_conflicts(): $HOME/.local is not a directory!" && exit 1
    ! [ -d ~/.local/bin ] && echo "check_conflicts(): $HOME/.local/bin is not a directory!" && exit 1

    # Ensure to NOT have conflicts with exising dotfiles that are not symlinks
    echo "STOW_FOLDERS: $STOW_FOLDERS"
    [ "$INCLUDE_SUBMODULES" = y ] && echo "STOW_SUBMODULE_FOLDERS: $STOW_SUBMODULE_FOLDERS"
    export timestamp=$(date +%s)
    recursive_conflicts_detection "$STOW_FOLDERS" "$STOW_SUBMODULE_FOLDERS"
    unset timestamp

    return 0
}

perform_stow() {
    # Convert comma-separated list to a space-separated
    __IFS_OLD=$IFS; IFS=,
    # Run stow for each package
    for folder in $STOW_FOLDERS; do
        fbn=${folder##*/}
        echo "Stowing $fbn..."
        stow -d "$DOTFILES/stow" -t "$HOME" "$fbn"
    done
    [ "$INCLUDE_SUBMODULES" = y ] && {
        for folder in $STOW_SUBMODULE_FOLDERS; do
            fbn=${folder##*/}
            echo "Stowing $fbn..."
            stow -d "$DOTFILES/stow_submodule" -t "$HOME" "$fbn"
        done
    }
    IFS=$__IFS_OLD; unset __IFS_OLD

    return 0
}

perform_unstow() {
    # Convert comma-separated list to a space-separated
    __IFS_OLD=$IFS; IFS=,
    # Run stow -D for each package
    for folder in $STOW_FOLDERS; do
        fbn=${folder##*/}
        echo "Unstowing $fbn..."
        stow -D -d "$DOTFILES/stow" -t "$HOME" "$fbn"
    done
    [ "$INCLUDE_SUBMODULES" = y ] && {
        for folder in $STOW_SUBMODULE_FOLDERS; do
            fbn=${folder##*/}
            echo "Unstowing $fbn..."
            stow -D -d "$DOTFILES/stow_submodule" -t "$HOME" "$fbn"
        done
    }
    IFS=$__IFS_OLD; unset __IFS_OLD

    return 0
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

