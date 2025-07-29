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

try_start_login_shell() {
    local flags
    local launcher
    local vscode_server_login
    launcher="$1"
    shift 1

    vscode_server_login=0
    if [ -n "$SSH_ORIGINAL_COMMAND" -a "$SHLVL" = 0 ]; then
        # a hack for vscode on remote server.
        #
        # If remote.SSH.remoteServerListenOnSocket is enabled, vscode doesn't start our login shell
        if [ "$TERM_PROGRAM" = vscode -a "$SSH_ORIGINAL_COMMAND" = sh ]; then
            vscode_server_login=1
        else
            eval exec "$SSH_ORIGINAL_COMMAND"
        fi
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

    if [ $vscode_server_login -eq 1 ]; then
        # start login shell manually
        exec "$launcher" exec --init zsh -l
    fi

    flags="--login"
    if [ -n "$SSH_CONNECTION" ]; then
        flags="$flags --motd"
    fi

    # transfer execution to launcher
    exec "$launcher" $flags "$@"
}

if [ -d "$NMK_HOME" ]; then
    try_start_login_shell "$NMK_HOME/bin/nmk" "$@"
fi

# well known locations
try_start_login_shell ~/.nmk/bin/nmk "$@"
try_start_login_shell ~/bin/nmk "$@"

global_nmk=$(command -v nmk 2>/dev/null)
if [ -x "$global_nmk" ]; then
    try_start_login_shell "$global_nmk" "$@"
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
