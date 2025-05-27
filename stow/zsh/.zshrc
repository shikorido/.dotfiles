[ -s ~/.zsh_env_persistent ] && . ~/.zsh_env_persistent

# msys2 as well as WSL on kali-linux do not define TMPDIR.
# Make sure TMPDIR is always defined.
if [ -z "$TMPDIR" ]; then
    if [ -f ~/.zsh_termux ]; then
        # PREFIX must be defined before sourcing this file.
        # Otherwise, the default value is used without
        # ownership checking (may be root).
        [ -z "$PREFIX" ] && export PREFIX=/data/data/com.termux/files/usr
        TMPDIR=$PREFIX/tmp
    else
        TMPDIR=/tmp
    fi
    export TMPDIR
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# For fzf-tab.
export TMPPREFIX=$TMPDIR/zsh
export USER=`id -un`

# Path to your Oh My Zsh installation.
export ZSH=~/.oh-my-zsh

if [ "$_MSYS2_" = 1 ]; then
    . ~/.config/personal/chpwdhook
    # Needed for _rg and _gh completions.
    fpath=( /mingw64/share/zsh/site-functions $fpath )
fi

# Completions from zsh-completions plugin.
# https://github.com/zsh-users/zsh-completions?tab=readme-ov-file#oh-my-zsh
# To avoid issues with redundant .zcompdump cache generation, do not load zsh-completions as a standard plugin.
fpath=( ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src $fpath )

# Completions from builtin plugins that are not sourced as plugins.
for plugin in docker-compose; do
    fpath=( ${ZSH:-~/.oh-my-zsh}/plugins/$plugin $fpath )
done

# Completions from dotfiles. E.g. for _dog.
fpath=( ~/.config/zsh/completions/site-functions $fpath )

# Update your ~/.zshrc configuration before sourcing oh-my-zsh:
autoload -U compinit && compinit



# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    fzf-tab
    zsh-autosuggestions
    zsh-syntax-highlighting
    #
    # It should be fast but why it slows down printing/pasting by 10 times..? (In msys2 at least).
    # Needs to be tested in linux envs.
    #fast-syntax-highlighting
    #
    # Replaced with fzf-tab:
    # Orig? https://dev.to/zeromeroz/setting-up-zsh-and-oh-my-zhs-with-autocomplete-plugins-1nml
    # Gist: https://gist.github.com/n1snt/454b879b8f0b7995740ae04c5fb5b7df
    # New:  https://gist.github.com/seungjulee/d72883c193ac630aac77e0602cb18270
    # Needs to be configured to not cause LAGS in windows (msys2) due to capturing system
    # and other highly populated folders.
    #zsh-autocomplete
    #
    # Must not be included in plugin list to avoid .zcompdump generation twice.
    # Sourced directly via fpath and compinit above.
    #zsh-completions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source ~/.zsh_profile

# alias luamake=/home/mpaulson/personal/lua-language-server/3rd/luamake/luamake

# bun completions
#[ -s "/home/mpaulson/.bun/_bun" ] && source "/home/mpaulson/.bun/_bun"

# Bun
#export BUN_INSTALL="/home/mpaulson/.bun"
#export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
#export PNPM_HOME="/home/mpaulson/.local/share/pnpm"
#export PATH="$PNPM_HOME:$PATH"
# pnpm end
# Turso
#export PATH="/home/mpaulson/.turso:$PATH"

