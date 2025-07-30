# By default, tmux windows are login shell.
# If zprofile is already sourced. It should not be sourced again.
# NMK_ZSH_PROFILE_INITIALIZED is set and check to prevent above situation.
if [[ $NMK_ZSH_PROFILE_INITIALIZED != "1" ]]; then
    # Initialize required variables if not start from our launcher
    if [[ ! -e $NMK_LAUNCHER_PATH ]]; then
        # Why this block is reached?
        #   - macOS shell (macOS doesn't start login shell on login)
        #   - ssh login to linux that doesn't call launcher
        #   - newly setup linux

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
    export NMK_ZSH_PROFILE_INITIALIZED=1
fi
# vi: ft=zsh
