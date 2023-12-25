# Compatible with both bash and zsh

# Get function definition
flavor_definition=$(declare -f $flavor)
original_flavor_name="original_$flavor"

# redefine the function by replacing its name with the new name
eval "${original_flavor_name}${flavor_definition#$flavor}"

# function named with the value of $flavor
eval "$flavor() {
  $original_flavor_name \"\$@\"
  local CONDA_RTN_CODE=\$?
  local CONDA_DEFAULT_ENV_COPY=\$CONDA_DEFAULT_ENV

  # check if function execution was successful
  if [ \$CONDA_RTN_CODE -ne 0 ]; then
    return \$CONDA_RTN_CODE
  fi

  if [[ \"\$@\" =~ .*\"activate\".* ]]; then
    local TMUX_SESSION_CONDA_ENVS=\$(tmux showenv TMUX_SESSION_CONDA_ENVS 2>/dev/null)
    if [[ $? -eq 0 ]]; then
      local OLD_VALUES=\$(echo \$TMUX_SESSION_CONDA_ENVS | sed \"s/TMUX_SESSION_CONDA_ENVS=//\")
      local CONDA_ENV_OTHER_PANES=\$(echo \$OLD_VALUES | sed \"s/\$TMUX_PANE:\w*[[:space:]]*//g\")
    fi
    tmux setenv TMUX_SESSION_CONDA_ENVS \"\$TMUX_PANE:\$CONDA_DEFAULT_ENV \$CONDA_ENV_OTHER_PANES\"
  fi
}"

# env variable set with the split-window or new-window keybind
if [[ -n \"$TMUX_PARENT_PANE_ID\" ]]; then
	TMUX_SESSION_CONDA_ENVS=$(tmux showenv TMUX_SESSION_CONDA_ENVS 2>/dev/null)
	if [ $? -eq 0 ]; then
		PATT="(?<=${TMUX_PARENT_PANE_ID}:).*?(?=([[:space:]]|$))"
		PARENT_CONDA_ENV=$(perl -e '$ENV{"TMUX_SESSION_CONDA_ENVS"} =~ /'"$PATT"'/; print $&')
		$flavor activate $PARENT_CONDA_ENV
	fi
	unset TMUX_SESSION_CONDA_ENVS PATT PARENT_CONDA_ENV
	unset TMUX_PARENT_PANE_ID
else
	[[ -n \"$CONDA_DEFAULT_ENV_COPY\" ]] && echo "Activate previous conda env '\$CONDA_DEFAULT_ENV_COPY'"
	$flavor activate $CONDA_DEFAULT_ENV_COPY
fi
