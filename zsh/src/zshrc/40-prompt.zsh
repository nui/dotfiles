() {
    local selected_prompt
    selected_prompt=${nmk_zsh_prompt:-horizontal}

    prompt $selected_prompt

    if [[ $selected_prompt == horizontal ]]; then
        # Don't display git branch symbol if terminal does not support 256 colors
        (( ${+commands[tput]} )) && (( $(command tput colors) < 256 )) && horizontal_branch_symbol=

        # Hide user and host in prompt if NMK_DEVELOPMENT is true by default,
        # this is not apply to zsh in ssh session
        [[ $NMK_DEVELOPMENT == true && -z $SSH_TTY ]] && horizontal[show_user_and_host]=0

        # Change prompt color on remote session
        if [[ -n $SSH_TTY || $SUDO_USER == ssm-user ]]; then
            if [[ $horizontal[base_color] == $horizontal_default[base_color] ]]; then
                horizontal[base_color]=magenta
            fi
        fi
    fi
}

