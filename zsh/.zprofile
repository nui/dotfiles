# By default, tmux windows are login shell.
# If zprofile is already sourced. It should not be sourced again.
# NMK_ZSH_PROFILE_INITIALIZED is set and check to prevent above situation.
if [[ $NMK_ZSH_PROFILE_INITIALIZED != "1" ]]; then
    source $ZDOTDIR/.zprofile.merged.zsh
    export NMK_ZSH_PROFILE_INITIALIZED=1
fi
# vi: ft=zsh
