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

typeset -g _nmk_update_ssh_socket_last_check=$EPOCHSECONDS
_nmk-update-ssh-socket() {
    [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] || (( $EPOCHSECONDS - $_nmk_update_ssh_socket_last_check > 300 )) && {
        eval $(tmux show-environment -s)
    }
    _nmk_update_ssh_socket_last_check=$EPOCHSECONDS
}

(( ${+commands[kubectl]} )) && {
    _nmk_precmd_functions+=_nmk-kubectl-precmd
    _nmk_preexec_functions+=_nmk-kubectl-preexec
}

[[ -n $TMUX && -n $SSH_CONNECTION && -S $SSH_AUTH_SOCK ]] && {
    _nmk_precmd_functions+=_nmk-update-ssh-socket
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
