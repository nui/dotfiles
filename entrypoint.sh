# shellcheck shell=dash

# This is a script that does launcher detection, inspects SSH_ORIGINAL_COMMAND then performs
# any required initialization, if command is not specified, it will launch zsh shell if available.
#
# Note:
# - This script is used by "command" option inside authorized_keys file
#    * sourcing is prefered ('. script.sh' format)
#    * or using it as script path ('sh script.sh' format)
#    * calling with ./script.sh format is not supported
# - All positional arguments are ignored
# - "exec -l" is not supported by dash shell



# -- begin prerequisites and fail-safe method -----------------------------------------------------
if [ -n "$ZSH_VERSION" ]; then
    # make zsh compatible with posix shell
    emulate sh
fi

# Determine shell program that run script
SHELL_PROG=""
if [ -n "$BASH_VERSION" ]; then
    SHELL_PROG=bash
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_PROG=zsh
else
    SHELL_PROG="$0"
fi

SHELL_OPTS=""
if [ "$SHELL_PROG" = zsh ]; then
    SHELL_OPTS="-o shwordsplit"
fi

pre_start() {
    if [ -n "${SSH_ORIGINAL_COMMAND+set}" ]; then
        _cmd="$SSH_ORIGINAL_COMMAND"

        # downgrade SSH_ORIGINAL_COMMAND to a normal variable
        unset SSH_ORIGINAL_COMMAND
        SSH_ORIGINAL_COMMAND="$_cmd"

        # Immediately execute command if starts with '\'
        # It is a fail-safe mechanism in case if there is something wrong with actual script body
        # or self updating corruption
        if [ "${_cmd#\\}" != "$_cmd" ]; then
            # shellcheck disable=SC2086
            exec "$SHELL_PROG" $SHELL_OPTS -c "$_cmd"
        fi
        unset _cmd
    fi
}
pre_start
# -- end prerequisites and fail-safe method -------------------------------------------------------



# -- actual script body ---------------------------------------------------------------------------
LAUNCHER_PATH=""

locate_launcher() {
    _launcher="$1"
    # fail if file doesn't exist or file is a broken symlink
    if [ ! -e "$_launcher" ]; then
        return 1
    fi
    # fail if file is not executable (for some reason)
    if [ ! -x "$_launcher" ]; then
        >&2 echo "$_launcher" is not executable
        return 1
    fi
    LAUNCHER_PATH="$_launcher"
    unset _launcher
}

fallback_no_launcher() {
    # If SSH_ORIGINAL_COMMAND is set, execute it
    if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
        # shellcheck disable=SC2086
        exec "$SHELL_PROG" $SHELL_OPTS -c "$SSH_ORIGINAL_COMMAND"
    fi

    # otherwise, fallback to start a login shell
    exec "$SHELL_PROG" -l
}

# See https://www.shellcheck.net/wiki/SC3050
escape() { printf "'%s'\\n" "$(printf '%s' "$1" | sed -e "s/'/'\\\\''/g")"; }

prepend_bin_dir_to_path() {
    _bin_dir=$(dirname "$LAUNCHER_PATH")
    PATH="$_bin_dir:$PATH"
    unset _bin_dir
}

execute_command() {
    _cmd="$SSH_ORIGINAL_COMMAND"
    case "$_cmd" in
        # If command is our binary, prepend its parent directory to PATH right before execution
        nmk | nmkup | nbox )
            prepend_bin_dir_to_path
            exec "$_cmd"
            ;;
        nmk[[:space:]]* | nmkup[[:space:]]* | nbox[[:space:]]* )
            prepend_bin_dir_to_path
            # shellcheck disable=SC2086
            exec "$SHELL_PROG" $SHELL_OPTS -c "$_cmd"
            ;;

        # If command is a shell, call it with "iexec" subcommand
        # - "iexec" initialize required environment variables of dotfiles project
        # - --set-user-shell set SHELL to our preferred login shell (zsh if available)
        sh | bash | zsh )
            exec "$LAUNCHER_PATH" iexec \
                --set-user-shell \
                "$_cmd"
            ;;
        sh[[:space:]]* | bash[[:space:]]* | zsh[[:space:]]* )
            exec "$LAUNCHER_PATH" iexec \
                --set-user-shell \
                --with-shell \
                --shell-prog="$SHELL_PROG" \
                "$_cmd"
            ;;

        # Otherwise, simply execute the command
        * )
            # shellcheck disable=SC2086
            exec "$SHELL_PROG" $SHELL_OPTS -c "$_cmd"
            ;;
    esac
}

main() {
    locate_launcher "$NMK_LAUNCHER_PATH" \
        || locate_launcher "${NMK_HOME:-$HOME/.nmk}/bin/nmk" \
        || locate_launcher "$(command -v nmk 2>/dev/null)" \
        || fallback_no_launcher

    [ -n "$SSH_ORIGINAL_COMMAND" ] && execute_command

    # Default to start a login shell
    exec "$LAUNCHER_PATH" --motd --login
}

# NOTE: we don't pass "$@" because this entrypoint should not be called with arguments
main

# vi: ft=sh
