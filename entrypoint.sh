#!/bin/sh

# A helper script to start login shell.
#
# Compatibility: dash, bash, and zsh

# This make bash not put following commands in history when sourcing this file
unset HISTFILE

if [ -n "$ZSH_VERSION" ]; then
    # make zsh behave like bash on word spliting
    setopt sh_word_split
fi

try_start() {
    local flags
    local launcher
    local exec_override_shell
    launcher="$1"
    shift 1

    exec_override_shell=0
    if [ -n "$SSH_ORIGINAL_COMMAND" -a "$SHLVL" = 0 ]; then
        case "$SSH_ORIGINAL_COMMAND" in
            *sh )
                # change SHELL to our shell rather than using a default login shell
                exec_override_shell=1
                ;;
            * )
                eval "$SSH_ORIGINAL_COMMAND"
                exit $?
        esac
    fi

    # return if file doesn't exist or broken symlink
    if [ ! -e "$launcher" ]; then
        return
    fi

    # return if file is not executable (for some reason)
    if [ ! -x "$launcher" ]; then
        >&2 echo "$launcher" is not executable
        return
    fi

    if [ $exec_override_shell -eq 1 ]; then
        exec "$launcher" exec --set-shell "$SSH_ORIGINAL_COMMAND"
    fi

    flags=""
    if [ -n "$SSH_CONNECTION" ]; then
        flags="$flags --motd"
    fi

    exec "$launcher" $flags exec -l zsh
}

try_start "${NMK_HOME:-$HOME/.nmk}/bin/nmk"

global_nmk=$(command -v nmk 2>/dev/null)
if [ -x "$global_nmk" ]; then
    try_start "$global_nmk"
fi

# If this line is reached, we didn't find candidate launcher, fallback to re-execute itself.
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
