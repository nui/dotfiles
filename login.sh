#!/bin/sh

# An entrypoint for ssh authorized_keys command option
#
# Intended usage
#   - as a command in authorized_keys "command" option
#   - call manually
#
# This script shouldn't handle SSH_ORIGINAL_COMMAND because it is managed by the caller

# Tell bash and zsh to not put following commands in history when sourcing this file
unset HISTFILE

if [ -n "$ZSH_VERSION" ]; then
    # make zsh compatible with posix shell
    emulate sh
fi

LAUNCHER_PATH=""

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
    [ -n "$BASH_VERSION" ] && exec bash -l
    [ -n "$ZSH_VERSION" ]  && exec zsh -l

    exec "${SHELL:-sh}" -l
}

main() {
    locate_launcher "$NMK_LAUNCHER_PATH" \
        || locate_launcher "${NMK_HOME:-$HOME/.nmk}/bin/nmk" \
        || locate_launcher "$(command -v nmk 2>/dev/null)" \
        || fallback_no_launcher

    flags="--login"
    if [ -n "$SSH_CONNECTION" ] && [ "$SHLVL" = 0 ]; then
        flags="$flags --motd"
    fi
    exec "$LAUNCHER_PATH" $flags "$@"
}

main "$@"

# vi: ft=sh
