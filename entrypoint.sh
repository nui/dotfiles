#!/bin/sh

# A helper script to start login shell.
#
# Compatibility: dash, bash, and zsh

if [ -n "$ZSH_VERSION" ]; then
    # make zsh behave like bash on word spliting
    setopt sh_word_split
fi

try_exec() {
    local command
    local flags
    local launcher
    launcher="$1"
    command="$SSH_ORIGINAL_COMMAND"

    # return if file doesn't exist or broken symlink
    if [ ! -e "$launcher" ]; then
        return 0
    fi

    # return if file is not executable (for some reason)
    if [ ! -x "$launcher" ]; then
        >&2 echo "$launcher" is not executable
        return 0
    fi

    if [ -n "$command" ]; then
        exec "$launcher" exec --set-shell --eval-cmd "$command"
    else
        if [ -n "$SSH_CONNECTION" ]; then
            flags="$flags --motd"
        fi
        exec "$launcher" $flags --login
    fi
}

main() {
    local current_exe
    local global_nmk
    local login_flag

    try_exec "${NMK_HOME:-$HOME/.nmk}/bin/nmk"

    global_nmk="$(command -v nmk 2>/dev/null)"
    if [ -x "$global_nmk" ]; then
        try_exec "$global_nmk"
    fi


    # If this line is reached, we didn't find candidate launcher

    # If command is set, execute it
    if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
        eval "$SSH_ORIGINAL_COMMAND"
        exit $?
    fi

    # fallback to re-execute itself.
    # N.B. MacOs doesn't have procfs, we fallback to /bin/sh
    current_exe="$(readlink -f /proc/$$/exe)"
    if [ ! -e "$current_exe" ]; then
        current_exe=/bin/sh
    fi

    # Bash and zsh support exec with login flag
    case "$current_exe" in
        */bash | */zsh) login_flag=-l ;;
        *) ;;
    esac

    exec $login_flag "$current_exe"
}

main "$@"
# vi: ft=sh
