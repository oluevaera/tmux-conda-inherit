#!/usr/bin/env bash

tmux_new_session_hook() {
    run-shell 'tmux set-environment -g SGREP "$(basename "$(command -v ggrep || command -v grep)")"'
}

main() {
    tmux_new_session_hook
}

main
