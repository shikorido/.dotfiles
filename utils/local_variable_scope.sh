# DOTFILES management
# master
# local_variable_scope.sh

[ "$_LOCAL_VARIABLE_SCOPE_H" ] && return 0
_LOCAL_VARIABLE_SCOPE_H=1

# Local variable scope implementation for POSIX.
# I can live without using it but let it be just in case.
# TODO. Make local environment scope just like SetLocal in batch.
#       Implies some SCOPE global variable that holds current scope counter.
#       Requires other functions and logic and should not be tied to _let/_unlet.
#       The local variable scope and local environment scope are inspired by:
#       https://stackoverflow.com/questions/18597697/posix-compliant-way-to-scope-variables-to-a-function-in-a-shell-script
#
# DONE. --FIX--. Detect whether variable was unsetted before _let
#                to unset it if no more references left.
#                Implies additional dynvar_${dynvar_name}_unsetted variable.
_let() {
    [ $# -eq 0 ] && return 1
    # _let can handle 3 cases:
    # $1 - name1, ..., $N - nameN (save values, do not overwrite)
    # $1 - name1=value1, ..., $N - nameN=valueN
    # $1 - name1, $2 - name2=value2, ... $N - nameN
    #      (save values if no assignment detected, otherwise save and assign specified value)
    #
    # This one is ambiguous and therefore not supported:
    # $1 - name, $2 - value

    # Arguments consistency check.
    # Has huge overhead but prevents execution if declarations and definitions are mixed.
    #for dynvar_name in "$@"; do
    #    if [ -z "$dynvar_val" ]; then
    #        [ "$dynvar_name" = "${dynvar_name#*=}" ] && dynvar_val=N || dynvar_val=Y
    #        continue
    #    fi
    #    # Leaving space for logging failures if needed.
    #    if [ "$dynvar_val" = N ]; then
    #        [ "$dynvar_name" = "${dynvar_name#*=}" ] || { unset dynvar_name dynvar_val; return 1; }
    #    else #Y
    #        [ "$dynvar_name" = "${dynvar_name#*=}" ] && { unset dynvar_name dynvar_val; return 1; }
    #    fi
    #done

    # We also should consider case where same variable name is used multiple times
    # whether in declaration or definition. How to properly handle this?
    for dynvar_name in "$@"; do
        [ "$dynvar_name" = "${dynvar_name#*=}" ] && dynvar_declare=1 || {
            dynvar_val=${dynvar_name#*=}
            dynvar_name=${dynvar_name%%=*}
            dynvar_declare=
        }

        eval dynvar_count=\$dynvar_${dynvar_name}_count
        [ -z "$dynvar_count" ] && {
            # TreeSitter just breaks at \\${$dynvar_name-1} so it was replaced with '$'{$dynvar_name-1}.
            if [ -z "`eval printf %s \\$$dynvar_name`" ] && [ "`eval printf %s '$'{$dynvar_name-1}`" = 1 ]; then
                eval dynvar_${dynvar_name}_unsetted=1
            fi
        }
        dynvar_count=$(( dynvar_count + 1 ))

        eval dynvar_${dynvar_name}_count=$dynvar_count
        eval dynvar_${dynvar_name}_oldval_$dynvar_count=\$$dynvar_name
        [ -z "$dynvar_declare" ] && eval $dynvar_name=\$dynvar_val
    done

    unset dynvar_name dynvar_val dynvar_count dynvar_declare
}
_unlet() {
    [ $# -eq 0 ] && return 0
    for dynvar_name in "$@"; do
        eval dynvar_count=\$dynvar_${dynvar_name}_count
        [ -n "$dynvar_count" ] && {
            eval $dynvar_name=\$dynvar_${dynvar_name}_oldval_$dynvar_count
            unset dynvar_${dynvar_name}_oldval_$dynvar_count
        }
        [ $(( dynvar_count - 1 )) -lt 1 ] && {
            unset dynvar_${dynvar_name}_count
            if [ -n "`eval printf %s \\$dynvar_${dynvar_name}_unsetted`" ]; then
                unset dynvar_${dynvar_name}_unsetted
                unset $dynvar_name
            fi
        } || {
            eval dynvar_${dynvar_name}_count=$(( dynvar_count - 1 ))
        }
    done
    unset dynvar_name dynvar_count
}

