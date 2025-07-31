#!/bin/sh

# A helper script to start login shell.
#
# Compatibility: dash, bash, and zsh

if [ -n "$ZSH_VERSION" ]; then
    # make zsh behave like bash on word spliting
    setopt sh_word_split
fi

try_start() {
    local exec_override_shell
    local flags
    local launcher
    launcher="$1"

    # return if file doesn't exist or broken symlink
    if [ ! -e "$launcher" ]; then
        return
    fi

    # return if file is not executable (for some reason)
    if [ ! -x "$launcher" ]; then
        >&2 echo "$launcher" is not executable
        return
    fi

    exec_override_shell=0
    if [ -n "$SSH_ORIGINAL_COMMAND" -a "$SHLVL" = 0 ]; then
        case "$SSH_ORIGINAL_COMMAND" in
            *sh )
                # change SHELL to our shell
                exec_override_shell=1
                ;;
            * )
                eval "$SSH_ORIGINAL_COMMAND"
                exit $?
        esac
    fi

    if [ $exec_override_shell -eq 1 ]; then
        exec "$launcher" exec --set-shell "$SSH_ORIGINAL_COMMAND"
    else
        if [ -n "$SSH_CONNECTION" ]; then
            flags="$flags --motd"
        fi
        exec "$launcher" $flags exec -l zsh
    fi
}

try_start "${NMK_HOME:-$HOME/.nmk}/bin/nmk"

global_nmk=$(command -v nmk 2>/dev/null)
if [ -x "$global_nmk" ]; then
    try_start "$global_nmk"
fi



# If this line is reached, we didn't find candidate launcher

# If command is set, execute it
if [ -n "$SSH_ORIGINAL_COMMAND" -a "$SHLVL" = 0 ]; then
    eval "$SSH_ORIGINAL_COMMAND"
    exit $?
fi

# fallback to re-execute itself.
# N.B. MacOs doesn't have procfs, we fallback to /bin/sh
current_exe=$(readlink -f /proc/$$/exe)
if [ ! -e "$current_exe" ]; then
    current_exe=/bin/sh
fi

login_flag=""
# Bash and zsh support exec with login flag
case "$current_exe" in
    */bash | */zsh) login_flag=-l ;;
    *) ;;
esac

exec $login_flag "$current_exe"
# vi: ft=sh
