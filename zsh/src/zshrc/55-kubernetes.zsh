if [[ -n $TMUX ]] && [[ -n $KUBERNETES_PORT ]]; then
    k-detach-other-clients-sighup-parent() {
        set -ex
        tmux detach-client -aP
    }
fi


() {
    # do nothing if TMOUT is already set
    (( TMOUT > 0 )) && return 0
    # only apply to kubectl exec process, and not the first process
    if [[ -n $KUBERNETES_SERVICE_HOST && $PPID == 0 && $$ != 1 ]]; then
        # logout if inactive for 15 minutes
        TMOUT=${nmk_kubectl_exec_idle_tmout:-$(( 15 * 60 ))}
    fi
}

