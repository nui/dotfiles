# How to use this function
#   - source this file from .zshenv at very beginning of file
#   - or symbolic link .zshenv to this file
#
#
# A helper function to set ZDOTDIR to DEVCON_<USERNAME>_ZDOTDIR in devcontainer environment
function {
    setopt localoptions noshwordsplit
    local -a exec_args
    local -a flags
    local launcher
    local zdotdir_env="DEVCON_${(U)USERNAME}_ZDOTDIR"
    local zsh_path
    # The "-z $ZDOTDIR" check is necessary, to prevent recursively source itself.
    if [[ -z $ZDOTDIR && -n $REMOTE_CONTAINERS_IPC && ${(P)zdotdir_env+set} = set ]]; then
        local zdotdir=${(P)zdotdir_env}
        if [[ -d $zdotdir ]]; then
            # vscode call zsh to determine environment variable using following format command
            # zsh -lic "echo -n $UUID; cat /proc/self/environ; echo -n $UUID"
            if [[ $ZSH_EXECUTION_STRING == echo*"cat /proc/self/environ; echo"* ]]; then
                # all conditions are met.
                # this shell is running from devcontainer to capture user environment variables
                flags+=-
                if [[ -o login ]]; then
                    flags+=l
                fi
                if [[ -o interactive ]]; then
                    flags+=i
                fi
                flags+=c
                zsh_path=/proc/self/exe
                zsh_path=${zsh_path:A}
                exec_args=($zsh_path ${(j::)flags} $ZSH_EXECUTION_STRING)
                launcher=${zdotdir:h}/bin/nmk
                if [[ -x $launcher ]]; then
                    # re-execute itself under our launcher
                    exec $launcher --no-std-log iexec ${exec_args[@]}
                else
                    # re-execute itself but with updated ZDOTDIR
                    export ZDOTDIR=$zdotdir
                    exec ${exec_args[@]}
                fi
            fi
        fi
    fi
}

