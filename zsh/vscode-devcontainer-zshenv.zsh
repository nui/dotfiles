# Uncomment this code to debug this script problem
# (
#     echo ">> date: $(date)"
#     echo ">> cmdline"
#     tr '\0' '\n' < /proc/$$/cmdline
#     echo ""
#     echo ">> printenv"
#     printenv
#     echo ""
#     echo ">> declare"
#     declare
#     echo ""
# ) >> ~/vscode-devcontainer.log


# How to use this function
#   - source this file from .zshenv at very beginning of file
#   - or symbolic link .zshenv to this file
#
# A helper function to set ZDOTDIR to DEVCON_<USERNAME>_ZDOTDIR in devcontainer environment
function {
    setopt localoptions noshwordsplit

    # userEnvProbe runs on zsh shell with one or both of following options
    #   - login
    #   - interactive
    if ! [[ -o login || -o interactive ]]; then
        return 0
    fi

    # "-n $ZDOTDIR" prevents recursively source this file if ZDOTDIR is set to home directory
    if [[ -n $ZDOTDIR || -z $REMOTE_CONTAINERS_IPC ]]; then
        return 0
    fi

    local devcon_zdotdir
    devcon_zdotdir="DEVCON_${(U)USERNAME}_ZDOTDIR"
    if [[ ${(P)devcon_zdotdir+set} = set ]]; then
        local zdotdir=${(P)devcon_zdotdir}
        if [[ -d $zdotdir ]]; then
            # vscode call zsh to determine environment variable using following format command
            # zsh -lic "echo -n $UUID; cat /proc/self/environ; echo -n $UUID"
            # it may use -lic, -lc or -ic flags, depends on userEnvProbe value
            if [[ $ZSH_EXECUTION_STRING == echo*"cat /proc/self/environ; echo"* ]]; then
                # all conditions are met.
                # this shell is running from devcontainer to capture user environment variables
                local -a flags
                flags+=-
                if [[ -o login ]]; then
                    flags+=l
                fi
                if [[ -o interactive ]]; then
                    flags+=i
                fi
                flags+=c

                # get path to binary of zsh running this script
                # we don't need to support macOS, because devcontainer runs on linux only
                local zsh_path
                zsh_path=/proc/self/exe
                # :A resolve symbolic links
                zsh_path=${zsh_path:A}

                local -a args
                args=($zsh_path ${(j::)flags} $ZSH_EXECUTION_STRING)

                # re-execute this command again under correct environment
                # if launcher is found, use the launcher, otherwise, set ZDOTDIR and execute

                # we assume that the launcher is located at $ZDOTDIR/../bin/nmk
                local launcher
                launcher=${zdotdir:h}/bin/nmk

                if [[ -x $launcher ]]; then
                    exec $launcher --no-std-log iexec ${args[@]}
                else
                    export ZDOTDIR=$zdotdir
                    exec ${args[@]}
                fi
            fi
        fi
    fi
}

