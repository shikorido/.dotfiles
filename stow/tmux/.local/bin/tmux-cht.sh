#!/usr/bin/env sh

selected=`cat ~/.cht-languages ~/.cht-command | fzf`
[ -z "$selected" ] && exit 0

printf %s 'Enter Query: '
read query

if grep -qs "$selected" ~/.cht-languages; then
	query=`printf %s "$query" | tr ' ' '+'`
	tmux neww sh -c "printf '%s\n' 'curl cht.sh/$selected/$query/' & curl 'cht.sh/$selected/$query' & while :; do sleep 1; done"
else
	tmux neww sh -c "curl -s 'cht.sh/$selected~$query' | less"
fi

