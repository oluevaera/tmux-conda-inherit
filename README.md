## Requirements

The following dependencies are required in order to use this plugin:

- [tmux](https://github.com/tmux/tmux) (>= 3.0)
- [tpm](https://github.com/tmux-plugins/tpm)
- [perl](https://github.com/Perl)
- [bash](https://www.gnu.org/software/bash/)/[zsh](https://www.zsh.org)

## Installation (via tpm)

Add the following lines to your `tmux.config` file:

```sh
set -g @plugin 'oluevaera/tmux-conda-inherit'
```

Extend your current new-window and split-window keybinds with `-e "TMUX_PARENT_PANE_ID=#{pane_id}`.
For example:
```sh
bind '%' run 'tmux split-window -c "#{pane_current_path}" -e "TMUX_PARENT_PANE_ID=#{pane_id}" -h'
bind '"' run 'tmux split-window -c "#{pane_current_path}" -e "TMUX_PARENT_PANE_ID=#{pane_id}" -v'
bind c run 'tmux new-window -c "#{pane_current_path}" -e "TMUX_PARENT_PANE_ID=#{pane_id}"'
```

Add the following lines to your `.bashrc` or `.zshrc`.  
Change the `$flavour` value to the conda version you're using (anaconda, mamba, micromamba, etc.)  
Make sure that the path corresponds you your tmux plugin path.
```sh
if [[ -n "$TMUX" ]] then
  export flavor='micromamba'
  source $HOME/.config/tmux/plugins/conda-inherit/conda-inherit.sh
fi
```

## FUTURE
Working on adding support for fish
