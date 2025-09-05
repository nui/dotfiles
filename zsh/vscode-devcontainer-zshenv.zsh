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


# A helper function to initialize zsh on vscode devcontainer environment
#
# There are two ways to use this function
#   1. source this file from .zshenv at very beginning of file
#   2. symbolic link .zshenv to this file
function {
    setopt localoptions noshwordsplit

    # userEnvProbe runs on zsh shell with one or both of following options
    #   - interactive
    #   - login
    #
    # return if running on non-interactive non-login shell
    if [[ ! -o interactive && ! -o login ]]; then
        return 0
    fi

    # return if $ZDOTDIR is set or not running under vscode
    #
    # The only case when ZDOTDIR is set, is when it is set to HOME directory
    if [[ -n $ZDOTDIR || -z $REMOTE_CONTAINERS_IPC ]]; then
        return 0
    fi

    if [[ -z $NMK_HOME || ! -d $NMK_HOME ]]; then
        return 0
    fi

    # vscode-server call zsh to determine environment variable using command with following format
    #
    #   zsh -lic "echo -n $UUID; cat /proc/self/environ; echo -n $UUID"
    #
    # $UUID is a random uuid
    #
    # it may use -lic, -lc or -ic, depends on userEnvProbe value
    #
    # There is no guarantee that vscode will always use this format
    # However, it is very unlikely to be changed

    # check if we are called by vscode to determine user environment variabls
    if [[ $ZSH_EXECUTION_STRING != "echo -n "* ]]; then
        return 0
    fi
    # split by "; "
    local arr=(${(@s/; /)ZSH_EXECUTION_STRING})
    if ! [[ ${#arr} == 3 && ${arr[1]} == ${arr[3]} && ${arr[2]} == "cat /proc/self/environ" ]]; then
        return 0
    fi

    # rebuild zsh command from /proc/self/cmdline via splitting by null byte
    # we don't need to support macOS, devcontainer runs on linux only
    local -a cmd_with_args=(${(0)"$(</proc/self/cmdline)"})



    # re-execute this command again under correct environment
    local launcher=${NMK_LAUNCHER_PATH:-$NMK_HOME/bin/nmk}
    # if the launcher is found and executable bit is set, use it
    if [[ -x $launcher ]]; then
        # --no-log is optional but we don't really need logging here
        exec $launcher --no-log iexec ${cmd_with_args[@]}
    # otherwise, set ZDOTDIR and execute
    else
        export ZDOTDIR=$NMK_HOME/zsh
        exec ${cmd_with_args[@]}
    fi
}

