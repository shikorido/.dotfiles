#!/usr/bin/env sh

# In order to avoid double zsh initialization - check if fzf is available.
! command -v fzf >/dev/null && {
	if [ -x ~/.fzf/bin/fzf ]; then
		PATH=~/.fzf/bin:$PATH
	else
		printf %s "Could not find fzf executable." && sleep 5 && exit 1
	fi
}

selected=`cat ~/.cht-languages ~/.cht-command | fzf`
[ -z "$selected" ] && exit 0

printf %s 'Enter Query: '
read query

if grep -qs "$selected" ~/.cht-languages; then
	query=`printf %s "$query" | tr ' ' '+'`
	sh -c "printf '%s\n' 'curl cht.sh/$selected/$query/' & curl 'cht.sh/$selected/$query' & while :; do sleep 1; done"
else
	sh -c "curl -s 'cht.sh/$selected~$query' | less"
fi

