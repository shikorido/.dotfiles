#ESCAPE_THIS='\n'

if [ $# -eq 0 ]; then
    # echo can still escape sequences depending on shell (f.e. dash).
    # printf %s will not escape anything which makes it suitable for testing.

    printf "%s:\n" 'printf "%s\n" "`printf %s _033]2B_`"'
    printf "%s\n" "`printf %s _033]2B_`"

    printf "%s:\n" 'printf "%s\n" "`printf %s _\033]2B_`"'
    printf "%s\n" "`printf %s _\033]2B_`"

    printf "%s:\n" 'printf "%s\n" "`printf %s _\\033]2B_`"'
    printf "%s\n" "`printf %s _\\033]2B_`"

    printf "%s:\n" 'printf "%s\n" "`printf %s _\\\033]2B_`"'
    printf "%s\n" "`printf %s _\\\033]2B_`"

    printf "%s:\n" 'printf "%s\n" "`printf %s _\\\\033]2B_`"'
    printf "%s\n" "`printf %s _\\\\033]2B_`"

    printf "%s:\n" 'printf "%s\n" "`printf %s _\\\\\033]2B_`"'
    printf "%s\n" "`printf %s _\\\\\033]2B_`"

else
    printf "%s:\n" 'printf "%s\n" "$(printf %s _033]2B_)"'
    printf "%s\n" "$(printf %s _033]2B_)"

    printf "%s:\n" 'printf "%s\n" "$(printf %s _\033]2B_)"'
    printf "%s\n" "$(printf %s _\033]2B_)"

    printf "%s:\n" 'printf "%s\n" "$(printf %s _\\033]2B_)"'
    printf "%s\n" "$(printf %s _\\033]2B_)"

    printf "%s:\n" 'printf "%s\n" "$(printf %s _\\\033]2B_)"'
    printf "%s\n" "$(printf %s _\\\033]2B_)"

    printf "%s:\n" 'printf "%s\n" "$(printf %s _\\\\033]2B_)"'
    printf "%s\n" "$(printf %s _\\\\033]2B_)"

    printf "%s:\n" 'printf "%s\n" "$(printf %s _\\\\\033]2B_)"'
    printf "%s\n" "$(printf %s _\\\\\033]2B_)"
fi

