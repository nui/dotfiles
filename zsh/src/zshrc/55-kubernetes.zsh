if [[ -n $TMUX ]] && [[ -n $KUBERNETES_PORT ]]; then
    k-detach-other-clients-sighup-parent() {
        set -ex
        tmux detach-client -aP
    }
fi
