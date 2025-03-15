# By default, tmux windows are login shell.
# If zprofile is already sourced. It should not be sourced again.
# NMK_PROFILE_INITIALIZED is set and check to prevent above situation.
if [[ $NMK_PROFILE_INITIALIZED != true ]]; then
    if [[ -e $NMK_LAUNCHER_PATH ]]; then
        # Launcher should already initialized required variables.
    else
        # Why this block is reached?
        #   - iTerm start new window
        #   - ssh login to linux that doesn't call launcher
        #   - newly setup linux

        # In our setup, ZDOTDIR always under NMK_HOME
        # N.B. This probably set wrong NMK_HOME if ZDOTDIR is symbolic link.
        (( ! ${+NMK_HOME} )) && export NMK_HOME=${ZDOTDIR:h}
        # I think this is worth to hard coded.
        # It may not work if NMK_HOME contains spaces.
        (( ! ${+VIMINIT} )) && export VIMINIT='source $NMK_HOME/vim/init.vim'
    fi

    if [[ -e $ZDOTDIR/zprofile ]]; then
        source $ZDOTDIR/zprofile
    fi
    export NMK_PROFILE_INITIALIZED=true
fi
# vi: ft=zsh
