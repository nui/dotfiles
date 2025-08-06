_nmk_precmd_functions=()
_nmk_preexec_functions=()

_nmk-kubectl-precmd() {
    if [[ -n $KUBECTL_CONTEXT ]]; then
        alias kubectl="kubectl --context=$KUBECTL_CONTEXT"
    fi
}

_nmk-kubectl-preexec() {
    if [[ -n $KUBECTL_CONTEXT ]]; then
        unalias kubectl
    fi
}

typeset -g _nmk_update_ssh_socket_tmux_last_check=0
_nmk-update-ssh-socket-tmux() {
    [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] && (( $EPOCHSECONDS - $_nmk_update_ssh_socket_tmux_last_check > 60 )) && {
        echo >&2 "prompt-hook ($0): update environment from tmux session"
        eval "$(tmux show-environment -s)"
        _nmk_update_ssh_socket_tmux_last_check=$EPOCHSECONDS
    }
}

_nmk-update-ssh-socket-vscode() {
    local -a sockets
    local new_socket
    [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] && {
        # see https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers
        # O = files owned by the effective user ID
        # om = sort by last modification, youngest first
        sockets=(/tmp/vscode-ssh-auth-*(Uom))
        [[ ${#sockets} -ge 1 ]] && {
            new_socket=${sockets[1]}
            echo >&2 "$0: update SSH_AUTH_SOCK to $new_socket"
            export SSH_AUTH_SOCK=$new_socket
        }
    }
}

(( ${+commands[kubectl]} )) && {
    _nmk_precmd_functions+=_nmk-kubectl-precmd
    _nmk_preexec_functions+=_nmk-kubectl-preexec
}

[[ -n $SSH_AUTH_SOCK ]] && {
    if [[ -n $TMUX && -n $SSH_CONNECTION ]]; then
        _nmk_precmd_functions+=_nmk-update-ssh-socket-tmux
    elif [[ $TERM_PROGRAM == vscode ]]; then
        if [[ $SSH_AUTH_SOCK == /tmp/vscode-ssh-auth-* ]]; then
            if [[ $REMOTE_CONTAINERS == true ]] || [[ -n $SSH_CONNECTION ]]; then
                _nmk-update-ssh-socket-vscode
            fi
        fi
    fi
}

_nmk_precmd() {
    local hook
    for hook in $_nmk_precmd_functions; do
        $hook
    done
}

_nmk_preexec() {
    local hook
    for hook in $_nmk_preexec_functions; do
        $hook
    done
}

add-zsh-hook precmd  _nmk_precmd
add-zsh-hook preexec _nmk_preexec
