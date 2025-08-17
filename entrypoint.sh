# shellcheck shell=sh

# Note
#   - This script must be sourced from "command" option in authorized_keys file
#   - All positional arguments are ignored
#   - we can't use "exec -l" because busybox exec doesn't support it

if [ -n "$ZSH_VERSION" ]; then
    # make zsh compatible with posix shell
    emulate sh
fi

LAUNCHER_PATH=""
SHELL_PROG=""

# Determine shell program that source this script
if [ -n "$BASH_VERSION" ]; then
    SHELL_PROG=bash
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_PROG=zsh
else
    SHELL_PROG="$0"
fi

locate_launcher() {
    launcher="$1"
    # return if file doesn't exist or broken symlink
    if [ ! -e "$launcher" ]; then
        return 1
    fi
    # return if file is not executable (for some reason)
    if [ ! -x "$launcher" ]; then
        >&2 echo "$launcher" is not executable
        return 1
    fi
    LAUNCHER_PATH="$launcher"
    unset launcher
}

fallback_no_launcher() {
    # If SSH_ORIGINAL_COMMAND is set, execute it
    if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
        exec "$SHELL_PROG" -c "$SSH_ORIGINAL_COMMAND"
    fi

    exec "$SHELL_PROG" -l
}

unexport_ssh_original_command() {
    # This script should not expose SSH_ORIGINAL_COMMAND to children
    if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
        _cmd="$SSH_ORIGINAL_COMMAND"
        unset SSH_ORIGINAL_COMMAND
        SSH_ORIGINAL_COMMAND="$_cmd"
        unset _cmd
    fi
}

# See https://www.shellcheck.net/wiki/SC3050
escape() { printf "'%s'\\n" "$(printf '%s' "$1" | sed -e "s/'/'\\\\''/g")"; }

prepend_nmk_bin_to_path() {
    nmk_bin_dir=$(dirname "$LAUNCHER_PATH")
    PATH="$nmk_bin_dir:$PATH"
}

execute_specified_command() {
    # handle SSH_ORIGINAL_COMMAND base on following conditions
    #   1. If it is a shell, update SHELL environment variable to zsh (if available).
    #      Tools that detect login shell from that variable will work properly
    #   2. if nmk/nmkup/nbox, update PATH then execute
    #   3. otherwise, evalute specified command
    case "$SSH_ORIGINAL_COMMAND" in
        # -- case 1 --
        sh | bash | zsh )
            exec "$LAUNCHER_PATH" exec --set-shell "$SSH_ORIGINAL_COMMAND"
            ;;
        sh[[:space:]]* | bash[[:space:]]* | zsh[[:space:]]* )
            exec "$LAUNCHER_PATH" exec --set-shell --eval-cmd "$SSH_ORIGINAL_COMMAND"
            ;;
        # -- case 2 --
        nmk | nmkup | nbox )
            prepend_nmk_bin_to_path
            exec "$SSH_ORIGINAL_COMMAND"
            ;;
        nmk[[:space:]]* | nmkup[[:space:]]* | nbox[[:space:]]* )
            prepend_nmk_bin_to_path
            exec "$SHELL_PROG" -c "$SSH_ORIGINAL_COMMAND"
            ;;
        # -- case 3 --
        * )
            exec "$SHELL_PROG" -c "$SSH_ORIGINAL_COMMAND"
            ;;
    esac
}

main() {
    unexport_ssh_original_command

    locate_launcher "$NMK_LAUNCHER_PATH" \
        || locate_launcher "${NMK_HOME:-$HOME/.nmk}/bin/nmk" \
        || locate_launcher "$(command -v nmk 2>/dev/null)" \
        || fallback_no_launcher

    [ -n "$SSH_ORIGINAL_COMMAND" ] && execute_specified_command

    # Default to start a login shell
    exec "$LAUNCHER_PATH" --motd --login
}

# NOTE: we don't specify "$@" because this entrypoint should not be called with arguments
main

# vi: ft=sh
