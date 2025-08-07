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
    local env_lines
    local socket_line
    local socket_path
    local tmux_output
    local tmux_outputs
    local update_env_command
    (( $EPOCHSECONDS - $_nmk_update_ssh_socket_tmux_last_check > 5 )) \
        && [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] && {
        _nmk_update_ssh_socket_tmux_last_check=$EPOCHSECONDS
        tmux_output="$(tmux show-environment \; display-message -p -- ----marker---- \; show-environment -s 2>/dev/null)"
        if (( $? )); then
            return $?
        fi
        tmux_outputs=("${(@s:----marker----:)tmux_output}")
        env_lines=(${(f)"${tmux_outputs[1]}"})
        socket_line="${env_lines[(r)SSH_AUTH_SOCK=*]}"
        [[ -n $socket_line ]] && {
            socket_path=${socket_line#SSH_AUTH_SOCK=}
            if [[ $socket_path == $SSH_AUTH_SOCK ]]; then
                # unchanged, do nothing
                return 0
            fi
            [[ -S $socket_path ]] && {
                update_env_command=${tmux_outputs[2]}
                eval "$update_env_command"
                echo >&2 "prompt-hook ($0): environment updated from tmux session"
            }
        }
    }
}

typeset -g _nmk_update_ssh_socket_vscode_last_check=0
_nmk-update-ssh-socket-vscode() {
    local socket
    local -a sockets
    local cur_socket
    (( $EPOCHSECONDS - $_nmk_update_ssh_socket_vscode_last_check > 5 )) \
        && [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] && {
        cur_socket=$SSH_AUTH_SOCK
        # see https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers
        # O = files owned by the effective user ID
        # om = sort by last modification, youngest first
        sockets=(/tmp/vscode-ssh-auth-*(Uom))
        # the first socket should be alive but we check first 3 sockets
        for socket in ${sockets[@]:0:3}; do
            if [[ -S $socket ]]; then
                export SSH_AUTH_SOCK=$socket
                echo >&2 "$0: SSH_AUTH_SOCK changed from $cur_socket to $socket"
                break
            fi
        done
        _nmk_update_ssh_socket_vscode_last_check=$EPOCHSECONDS
    }
}

(( ${+commands[kubectl]} )) && {
    _nmk_precmd_functions+=_nmk-kubectl-precmd
    _nmk_preexec_functions+=_nmk-kubectl-preexec
}

# register a hook running on every prompt line
[[ -n $SSH_AUTH_SOCK ]] && {
    # tmux session on remote server
    if [[ -n $TMUX && -n $SSH_CONNECTION ]]; then
        _nmk_precmd_functions+=_nmk-update-ssh-socket-tmux
    elif [[ $TERM_PROGRAM == vscode ]]; then
        if [[ $SSH_AUTH_SOCK == /tmp/vscode-ssh-auth-* ]]; then
            # vscode on remote server or devcontainer
            if [[ $REMOTE_CONTAINERS == true ]] || [[ -n $SSH_CONNECTION ]]; then
                _nmk_precmd_functions+=_nmk-update-ssh-socket-vscode
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
