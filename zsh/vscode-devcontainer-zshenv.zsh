# Uncomment this code to debug this script problem
# (
#     echo ">> date: $(date)"
#     echo ">> cmdline"
#     tr '\0' '\n' < /proc/$$/cmdline
#     echo ""
#     echo ">> declare -x"
#     declare -x
#     echo ""
#     echo ">> declare"
#     declare
#     echo ""
# ) >> ~/vscode-devcontainer.log


# A helper function to set ZDOTDIR to DEVCON_<USERNAME>_ZDOTDIR in vscode devcontainer environment
#
# For example, if current user is "user", it will use "DEVCON_USER_ZDOTDIR" variable
#
# There are two ways to use this function
#   1. source this file from .zshenv at very beginning of file
#   2. symbolic link .zshenv to this file
function {
    setopt localoptions noshwordsplit

    # userEnvProbe runs on zsh shell with one or both of following options
    #   - login
    #   - interactive
    if [[ ! -o login && ! -o interactive ]]; then
        return 0
    fi

    # "-n $ZDOTDIR" prevents recursively source this file if ZDOTDIR is set to home directory
    if [[ -n $ZDOTDIR || -z $REMOTE_CONTAINERS_IPC ]]; then
        return 0
    fi

    local devcon_zdotdir="DEVCON_${(U)USERNAME}_ZDOTDIR"
    local zdotdir=${(P)devcon_zdotdir}
    if [[ -z $zdotdir || ! -d $zdotdir ]]; then
        return 0
    fi
    # vscode-server call zsh to determine environment variable using command with following format
    #
    #   zsh -lic "echo -n $UUID; cat /proc/self/environ; echo -n $UUID"
    #
    # $UUID is a random uuid
    #
    # it may use -lic, -lc or -ic flags, depends on userEnvProbe value
    if [[ $ZSH_EXECUTION_STRING != "echo -n "* ]]; then
        return 0
    fi
    # split by "; "
    local arr=(${(@s/; /)ZSH_EXECUTION_STRING})
    if ! [[ ${#arr} == 3 && ${arr[1]} == ${arr[3]} && ${arr[2]} == "cat /proc/self/environ" ]]; then
        return 0
    fi

    # at this point, all test conditions are satisfied.

    # construct correct zsh flags by testing options
    local flags=-
    if [[ -o login ]]; then
        flags+=l
    fi
    if [[ -o interactive ]]; then
        flags+=i
    fi
    flags+=c

    # resolve binary path of current running zsh
    # we don't need to support macOS, devcontainer runs on linux only
    local zsh_path=/proc/self/exe
    # :A resolve symbolic links
    zsh_path=${zsh_path:A}

    local -a args
    args=($zsh_path $flags $ZSH_EXECUTION_STRING)

    # re-execute this command again under correct environment

    # we assume that the launcher is located at $ZDOTDIR/../bin/nmk
    local launcher=${zdotdir:h}/bin/nmk

    # if the launcher is found and executable bit is set, use it
    if [[ -x $launcher ]]; then
        exec $launcher --no-log iexec ${args[@]}
    # otherwise, set ZDOTDIR and execute
    else
        export ZDOTDIR=$zdotdir
        exec ${args[@]}
    fi
}

