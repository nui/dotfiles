# By default, tmux windows are login shell.
# If zprofile is already sourced. It should not be sourced again.
# NMK_PROFILE_INITIALIZED is set and check to prevent above situation.
if [[ $NMK_PROFILE_INITIALIZED != "1" ]]; then
    if [[ -e $NMK_LAUNCHER_PATH ]]; then
        # Launcher should already initialized required variables.
    else
        # Why this block is reached?
        #   - iTerm start new window
        #   - ssh login to linux that doesn't call launcher
        #   - newly setup linux

        # Setup required variables in case if zsh is not started from our launcher

        (( ! ${+NMK_HOME} )) && {
            # In our setup, ZDOTDIR always under NMK_HOME
            # :A modifier is used to follow symlink correctly
            export NMK_HOME=${ZDOTDIR:A:h}
        }
        (( ! ${+VIMINIT} )) && export VIMINIT="source ${NMK_HOME:q}/vim/init.vim"
    fi

    if [[ -e $ZDOTDIR/zprofile ]]; then
        source $ZDOTDIR/zprofile
    fi
    export NMK_PROFILE_INITIALIZED=1
fi
# vi: ft=zsh
