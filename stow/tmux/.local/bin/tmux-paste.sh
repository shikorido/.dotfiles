#!/usr/bin/env bash

# Check if win32yank is available (WSL)
if command -v win32yank.exe >/dev/null; then
    CLIP=$(win32yank.exe -o --lf)
    #win32yank.exe -o --lf
# Check for xclip (linux)
elif command -v xclip >/dev/null; then
    CLIP=$(xclip -out -selection clipboard)
    #xclip -out -selection clipboard
# Fallback: tmux buffer only
else
    CLIP=""
    #cat >/dev/null
fi

# Detect if the current tmux pane runs nvim
PANE_CMD=$(tmux display -p '#{pane_current_command}')

if [ "$PANE_CMD" = "nvim" ]; then
    # Send 'a' to enter insert mode (send Escape to cancel current action/mode)
    tmux send-keys Escape Escape a
    sleep 0.01
fi

# Paste buffer
tmux set-buffer -- "$CLIP"
tmux paste-buffer

# Go to the selection start if running nvim
#if [ "$PANE_CMD" = "nvim" ]; then
#    tmux send-keys Escape \` \< l
#    sleep 0.01
#fi

