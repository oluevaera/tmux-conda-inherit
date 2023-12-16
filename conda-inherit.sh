#!/usr/bin/env bash

flavor_definition=$(declare -f $flavor)
original_flavor_name="original_$flavor"

eval "original_$flavor_definition" 2>/dev/null
if [ $? -ne 0 ]; then
	eval "$flavor_definition {
        command $flavor \"\$@\"
    }"
fi

$flavor() {
	$original_flavor_name "$@"
	local CONDA_RTN_CODE=$?

	CONDA_DEFAULT_ENV_COPY=$CONDA_DEFAULT_ENV

	[ $CONDA_RTN_CODE -ne 0 ] && return $CONDA_RTN_CODE

	if [[ "$@" =~ .*"activate".* ]]; then
		local TMUX_SESSION_CONDA_ENVS=$(tmux showenv TMUX_SESSION_CONDA_ENVS 2>/dev/null)
		if [[ $? -eq 0 ]]; then
			local OLD_VALUES=$(echo $TMUX_SESSION_CONDA_ENVS | sed "s/TMUX_SESSION_CONDA_ENVS=//")
			local CONDA_ENV_OTHER_PANES=$(echo $OLD_VALUES | sed "s/$TMUX_PANE:\w*[[:space:]]*//g")
		fi
		tmux setenv TMUX_SESSION_CONDA_ENVS "$TMUX_PANE:$CONDA_DEFAULT_ENV $CONDA_ENV_OTHER_PANES"
	fi
}

if [[ -n "$TMUX_PARENT_PANE_ID" ]]; then
	TMUX_SESSION_CONDA_ENVS=$(tmux showenv TMUX_SESSION_CONDA_ENVS 2>/dev/null)
	if [ $? -eq 0 ]; then
		PATT="(?<=${TMUX_PARENT_PANE_ID}:).*?(?=([[:space:]]|$))"
		PARENT_CONDA_ENV=$(echo $TMUX_SESSION_CONDA_ENVS | $SGREP -oP "$PATT" | head -1)
		$flavor activate $PARENT_CONDA_ENV
	fi
	unset TMUX_SESSION_CONDA_ENVS PATT PARENT_CONDA_ENV
	unset TMUX_PARENT_PANE_ID
else
	[[ -n "$CONDA_DEFAULT_ENV_COPY" ]] && echo "Activate previous conda env '$CONDA_DEFAULT_ENV_COPY'"
	$flavor activate $CONDA_DEFAULT_ENV_COPY
fi
