() {
    local selected_prompt
    selected_prompt=${nmk_zsh_prompt:-horizontal}

    prompt $selected_prompt

    if [[ $selected_prompt == horizontal ]]; then
        # Don't display git branch symbol if terminal does not support 256 colors
        [[ -n $TERM ]] && (( ${+commands[tput]} )) && (( $(command tput colors) < 256 )) && horizontal_branch_symbol=

        # Hide user and host in prompt if NMK_DEV is set to 1
        # this is not apply to zsh in ssh session and shell running in devcontainer
        (( ${NMK_DEV:-0} )) && [[ -z $SSH_TTY && $REMOTE_CONTAINERS != true ]] && {
            if (( horizontal[show_user_and_host] == -1 )) && {
                horizontal[show_user_and_host]=0
            }
        }

        # Change prompt color on remote session
        # NOTE: we can't use SSH_TTY because vscode-terminal on remote server doesn't set it
        if [[ -n $SSH_CONNECTION || $SUDO_USER == ssm-user ]]; then
            if [[ $horizontal[base_color] == $horizontal_default[base_color] ]]; then
                horizontal[base_color]=magenta
            fi
        fi
    fi
}

