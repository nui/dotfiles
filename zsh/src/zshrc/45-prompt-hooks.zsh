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
        eval "$(tmux show-environment -s)"
        echo >&2 "prompt-hook ($0): environment updated from tmux session"
        _nmk_update_ssh_socket_tmux_last_check=$EPOCHSECONDS
    }
}

_nmk-update-ssh-socket-vscode() {
    local -a sockets
    local cur_socket
    [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] && {
        cur_socket=$SSH_AUTH_SOCK
        # see https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers
        # O = files owned by the effective user ID
        # om = sort by last modification, youngest first
        sockets=(/tmp/vscode-ssh-auth-*(Uom))
        for socket in ${sockets[@]}; do
            if [[ -S $socket ]]; then
                export SSH_AUTH_SOCK=$socket
                echo >&2 "$0: SSH_AUTH_SOCK changed from $cur_socket to $socket"
                return 0
            fi
        done
    }
}

(( ${+commands[kubectl]} )) && {
    _nmk_precmd_functions+=_nmk-kubectl-precmd
    _nmk_preexec_functions+=_nmk-kubectl-preexec
}

[[ -n $SSH_AUTH_SOCK ]] && {
    # tmux session on remote server
    if [[ -n $TMUX && -n $SSH_CONNECTION ]]; then
        # register a hook running on every prompt line
        _nmk_precmd_functions+=_nmk-update-ssh-socket-tmux
    elif [[ $TERM_PROGRAM == vscode ]]; then
        if [[ $SSH_AUTH_SOCK == /tmp/vscode-ssh-auth-* ]]; then
            # vscode on remote server or devcontainer
            if [[ $REMOTE_CONTAINERS == true ]] || [[ -n $SSH_CONNECTION ]]; then
                # runs on shell start (new terminal/revived terminal)
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
