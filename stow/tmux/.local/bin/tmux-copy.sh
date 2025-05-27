#!/usr/bin/env sh

# Check if win32yank is available (WSL)
if command -v win32yank.exe >/dev/null; then
    cat | win32yank.exe -i --crlf
# Check for xclip (linux)
elif command -v xclip >/dev/null; then
    cat | xclip -in -selection primary -f | xclip -in -selection clipboard
# Fallback: tmux buffer only
else
    cat >/dev/null
fi

