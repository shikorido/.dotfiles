#/usr/bin/sh

y="123 123"
var=y

print_args() { for arg in "$@"; do printf "%s\n" "$arg"; done }

#echo `echo \`printf "%s _ %s" "$y"\``
#print_args "`eval print_args \\"\`printf "%s _ %s" "$y"\`\\"`"
#eval print_args \"$(printf "%s _ %s" "\$$var")\"
#eval print_args \"`printf "%s _ %s" "\\$$var"`\"

# UPD. Backticks do not escape everything like in regular shell pass without quotes.
#      In my tests, backticks make $, \, ` escapable if not surrounded by double quotes
#      (single quote is not considered escapable thus backslash remains, the same stays for any non-escapable character).
#      If backticks are surrounded by double quotes the behavior changes slightly.
#      Now backticks surrounded by double quotes make $, \, `, " escapable which means my previous tests below may be wrong in terms of
#      amount of backslashes used.
#      Single quotes have no additional behavior and therefore behave similar (or identical) to non double quoted case ($, \, `).
#
# So how can we test that non-escapable characters do not trigger backslash exhaustion in backticks escaping passes? Here it is.
# Single quotes are still respected by outer shell pass thus everything inside stay literal after backticks escaping passes.
printf "%s\n" `printf %s '\\\1'`  # \\1
printf "%s\n" `printf %s '\''_'`  # \_
printf "%s\n" `printf %s '\"'`    # \"
printf "%s\n" "`printf %s '\"'`"  # "
#
# Also note that double quotes change escapable characters only if outer shell sees double quotes.
# In other words, the following has identical output cause backslash does not escape ".
printf "%s\n" `printf %s_%s \"\`printf %s \"1\"\`\"`   # ""1""_
printf "%s\n" `printf %s_%s \"\`printf %s \\"1\\"\`\"` # ""1""_
#
# The important quirk is that outer shell notifies only relevant backticks layer whether it is wrapped in double quotes.
# We could think that if outer backticks are surrounded by double quotes
# then any inner backticks will inherit that behavior and consider double quote as escapable character.
# However, this is not the case:
# Both backticks layers are surrounded by raw ".
printf "%s\n" "`printf %s \\""\`printf %s \\\\"\`"`"  # ""
# Only outer backticks layer is surrounded. Looks fine, right?
printf "%s\n" "`printf %s \\"\`printf %s \\\\"\``"    # ""
# However, it can be simplified. Lets look how the previous line is processed in general.
# 1. Outer backticks (wrapped in ") pass gives \\" from \\\\" inside inner backticks.
# 2. Inner backticks (not wrapped in ") pass gives \" from \\"  inside its own backticks layer.
# 3. Outer shell finalizes backticks layers from innermost to outermost.
#    Escapes everything depending on context (with or without quotes),
#    performs expansions, collects words from quotes,
#    invokes corresponding command in substitution.
# Look at step 2 again. In my assumption, double quotes
# only change escaping behavior for backticks they wrap.
# Inner backticks are not wrapped, thus \" should stay as-is cause " would be considered non-escapable.
# Which leads to:
printf "%s\n" "`printf %s \\"\`printf %s \\"\``"      # ""
# 1. Outer backticks (wrappend in ") pass gives \" from \\" inside inner backticks.
# 2. Inner backticks (not wrapped in ") pass gives \" from \" inside its own backticks layer (the same behavior would apply for inner backticks layers).
# 3. Thus, outer shell handles \" as escape (look at 041,0,z example below, shell will try to escape everything if no double quotes in play)
#    and passes raw " to a corresponding command.
#
# To be explained. Just a couple tests.
#printf "%s\n" `printf %s_%s \"\`printf %s \\"1\\"\`\"`
#""1""_
#printf "%s\n" `printf %s_%s "\`printf %s \\"1\\"\`"`
#1_
#$ printf "%s\n" `printf %s_%s \"\`printf %s \"1\"\`\"`
#""1""_
#$ printf "%s\n" `printf %s_%s \""\`printf %s \"1\"\`"\"`
#"1"_
#$ printf "%s\n" `printf %s_%s \""\`printf %s \"1\"\`"`
#"1_
#printf "%s\n" `printf %s_%s \""\`printf %s \\"1\\"\`"`
#"1_
#printf "%s\n" `printf %s_%s \""\`printf %s \\\"1\\\"\`"`
#""1"_
#printf "%s\n" "`printf %s_%s \\""\`printf %s \\\\"1\\\\"\`"`"
#""1"_
# UPD ends here.

# IFS splitted output is passed to %s which prints arguments glued one by one (1 glued line printed at "%s\n").
printf "%s\n" `printf %s \`eval printf \\\\"%s _ %s\\\\" \\\\"\\\\$$var\\\\"\``
# IFS splitted output is passed to "%s\n" which prints arguments with LF one by one (3 new lines printed).
printf "%s\n" `printf %s "\`eval printf \\\\"%s _ %s\\\\" \\\\"\\\\$$var\\\\"\`"`
# Avoiding IFS splitting surrounding sensitive parts in double quotes.
printf "%s\n" "`printf %s "\`eval printf \\\\"%s _ %s\\\\" \\\\"\\\\$$var\\\\"\`"`"
# Modern alternative. Look how we do not care anymore about escapes preservation.
printf "%s\n" "$(printf %s "$(eval printf \"%s _ %s\" \"\$$var\")")"
# And again. Note how single backticks force us to preserve escapings due to additional escape passes.
printf "%s\n" "`eval printf \\"%s _ %s\\" \\"\\$$var\\"`"
# UPD. Perhaps I meant a subshell invoked by command substitution.
# Backticks handle escapes similar to regular shell parsing without surrounding quotes.
printf "%s\n" \041      # Escapes 041 (or 0?) but does not interpret it to !.
printf "%s\n" \\041     # \ escapes \.
printf "%s\n" \\\041    # Escapes 041 but does not interpret it to ! and \ escapes \.
printf "%s\n" \\\\041   # \ escapes \.
printf "%s\n" \\\\\041  # Escapes 041 but does not interpret it to ! and \ escapes \.
printf "%s\n" \0        # Escapes 0 but does not interpret it.
printf "%s\n" \\0       # \ escapes \.
printf "%s\n" \z        # Escapes z but does not interpret it (to what?).
printf "%s\n" \\z       # \ escapes \.
printf "%s\n" "\041"    # Backslash does not escape 041 now.
printf "%s\n" "\\041"   # Same as above but " change escaping behavior.
                        # Only (maybe) $, \, " are treated as escapable thus \ escapes \ too.
# What about backslashes in single quotes?
# OK. Thats more about how eval works, not backticks.
#     No backslashes and '$' survives for eval re-parse (handled by outer shell pass and preserves $).
printf "%s\n" "`printf %s "\`eval printf \\\\"%s _ %s\\\\" \\\\"'$'$var\\\\"\`"`"
# WARN. Thats more about how eval works, not backticks. We must preserve single quotes for eval
#       and avoid its handling as strings by outer shell pass. Even single escape suffice to pass
#       single quotes for eval re-parse.
printf "%s\n" "`printf %s "\`eval printf \'%s _ %s\' \\\\"'$'$var\\\\"\`"`"
# OK. Assume we want to save one backslash before $. How could we do that in a modern way?
#     Obviously using single quotes. Eval was removed from this example.
printf "%s\n" "$(printf %s "$(printf '%s _ %s' '\$'"$var")")"
# WARN. What about backticks then? Remember. Every layer of backticks requires escapes preservation.
#       If we want to save \ in front of $ we must escape \ twice (in my example I use two backticks layers).
#       Here is what we mean by saying: backticks share the same quoting context,
#       in a nutshell: backticks do not guard quotes (e.g. single quotes around $)
#       and escapes (if any used - must be re-escaped to comply with backticks layers count)
#       from outer shell.
printf "%s\n" "`printf %s "\`printf '%s _ %s' '\\\\$'"$var"\`"`"

#printf "%s\n" "`printf %s "\`eval printf \'%s _ %s\' \\\\"'$'$var\\\\"\`"`"

#printf "%s\n" "`printf %s "\`eval printf \\\\"%s _ %s\\\\" \\\\"\\\\$$var\\\\"\`"`"
#printf "%s\n" "`eval print_args \\"\`printf "%s _ %s" "\\\\\$$var"\`\\"`"

#printf %s "`eval printf \\"%s _ %s\\" \\"'$'$var\\"`"

