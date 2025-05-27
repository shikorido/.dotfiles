# DOTFILES management
# master
# logger.sh

[ "$_LOGGER_H" = 1 ] && return 0
_LOGGER_H=1

# Basic text attributes
export ESC='\033'
export RESET=${ESC}[0m
# Makes BOLD and BRIGHT altogether.
export BOLD=${ESC}[1m
export FAINT=${ESC}[2m
export ITALIC=${ESC}[3m
export UNDERLINE=${ESC}[4m
export BLINK_RARE=${ESC}[5m
export BLINK_FAST=${ESC}[6m
export REVERSE=${ESC}[7m
export HIDDEN=${ESC}[8m
export STRIKETHROUGH=${ESC}[9m

# Regular Colors
# Foreground
export BLACK="${ESC}[38;5;0m"
export RED="${ESC}[38;5;1m"
export GREEN="${ESC}[38;5;2m"
export YELLOW="${ESC}[38;5;3m"
export BLUE="${ESC}[38;5;4m"
export MAGENTA="${ESC}[38;5;5m"
export CYAN="${ESC}[38;5;6m"
export WHITE="${ESC}[38;5;7m"
# Background
export BLACK_BG="${ESC}[48;5;0m"
export RED_BG="${ESC}[48;5;1m"
export GREEN_BG="${ESC}[48;5;2m"
export YELLOW_BG="${ESC}[48;5;3m"
export BLUE_BG="${ESC}[48;5;4m"
export MAGENTA_BG="${ESC}[48;5;5m"
export CYAN_BG="${ESC}[48;5;6m"
export WHITE_BG="${ESC}[48;5;7m"

# Bright Colors
# Foreground
export BR_BLACK="${ESC}[38;5;8m"
export BR_RED="${ESC}[38;5;9m"
export BR_GREEN="${ESC}[38;5;10m"
export BR_YELLOW="${ESC}[38;5;11m"
export BR_BLUE="${ESC}[38;5;12m"
export BR_MAGENTA="${ESC}[38;5;13m"
export BR_CYAN="${ESC}[38;5;14m"
export BR_WHITE="${ESC}[38;5;15m"
# Background
export BR_BLACK_BG="${ESC}[48;5;8m"
export BR_RED_BG="${ESC}[48;5;9m"
export BR_GREEN_BG="${ESC}[48;5;10m"
export BR_YELLOW_BG="${ESC}[48;5;11m"
export BR_BLUE_BG="${ESC}[48;5;12m"
export BR_MAGENTA_BG="${ESC}[48;5;13m"
export BR_CYAN_BG="${ESC}[48;5;14m"
export BR_WHITE_BG="${ESC}[48;5;15m"

# COLOR=$1 STR=$2
printc() {
    if [ $# -ne 2 ]; then
        printf "%s [$BOLD${RED}ERROR$RESET] printc: 2 arguments expected, got %d${RESET}\n" "`date '+%Y-%m-%d %H:%M:%S'`" $#
        return 1
    fi
    # POSIX BRE and ERE character classes.
    # https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html
    # New document version.
    # https://pubs.opengroup.org/onlinepubs/9799919799
    # Colorize if stdin (fd 1) is attached to a terminal.
    if [ -t 1 ]; then
        eval printf \"\${`printf %s "$1" | tr '[:lower:]' '[:upper:]'`}%s\$RESET\\n\" \"\$2\"
    else
        printf "%s\n" "$2"
    fi
    # It's very annoying to write expansions for every call ("${BLACK}", "${YELLOW}").
    #printf "$1%s$RESET\n" "$2"
    # However it is useful if we use extended colors.
    # ==256-color==
    # Foreground: "${ESC}[38;5;<n>m"
    # Background: "${ESC}[48;5;<n>m"
    # n = [0..255]
    # 0-15    - ANSI
    # 16-231  - 6x6x6 RGB color cube (6-based RGB palette where R - MSD, G - Middle Digit, B - LSD).
    # 232-255 - 24 levels of grayscale (from black to white)
    #
    # ==true-color==
    # Foreground: "${ESC}[38;2;<r>;<g>;<b>m"
    # Background: "${ESC}[48;2;<r>;<g>;<b>m"
    # r = [0..255]
    # g = [0..255]
    # b = [0..255]
}
# Similar to printc but takes format string.
# COLOR=$1 FSTR=$2 FARG1=$3 FARG2=$4...
printfc() (
    if [ $# -lt 2 ]; then
        printf "%s [$BOLD${RED}ERROR$RESET] printfc: Error: at least 2 arguments expected, got %d${RESET}\n" "`date '+%Y-%m-%d %H:%M:%S'`" $#
        exit 1
    fi
    # Does not work unfortunately. I'm forced to use variables and change printfc to a subshell function.
    #eval printf \"\${`printf %s "$1" | tr '[:lower:]' '[:upper:]'`}$2\$RESET\" \"\$@\" `shift 2 2>/dev/null`
    color=$1
    fstr=$2
    shift 2
    # Colorize if stdin (fd 1) is attached to a terminal.
    if [ -t 1 ]; then
        eval printf \"\${`printf %s "$color" | tr '[:lower:]' '[:upper:]'`}$fstr\$RESET\" \"\$@\"
    else
        printf "$fstr" "$@"
    fi
)
# MSG is considered to be FMSG if $# is greater than 3.
# LEVEL=$1 FUNC=$2 MSG=$3 ([FARG1=$4],[FARG2=$5],...)
log() (
    timestamp=`date '+%Y-%m-%d %H:%M:%S'`
    if [ $# -lt 3 ]; then
        printf "%s [${RED}ERROR$RESET] log: At least 3 arguments expected, got %d${RESET}\n" "$timestamp" $#
        exit
    fi
    level=`printf %s "$1" | tr '[:lower:]' '[:upper:]'`
    func=$2
    msg=$3

    if [ -t 1 ]; then
        case $level in
            INFO)  COLOR=$GREEN  ;;
            WARN)  COLOR=$YELLOW ;;
            ERROR) COLOR=$RED    ;;
            DEBUG) COLOR=$CYAN   ;;
            *)     COLOR=$RESET  ;;
        esac
    else
        unset BOLD COLOR RESET
    fi

    if [ $# -eq 3 ]; then
        printf "%s $BOLD$COLOR%-5s$RESET %s: %s\n" "$timestamp" "$level" "$func" "$msg"
    else
        shift 3
        printf "%s $BOLD$COLOR%-5s$RESET %s: $msg" "$timestamp" "$level" "$func" "$@"
    fi
)

