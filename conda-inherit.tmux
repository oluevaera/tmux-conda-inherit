run-shell 'tmux set-environment -g SGREP "$(basename "$(command -v ggrep || command -v grep)")"'
