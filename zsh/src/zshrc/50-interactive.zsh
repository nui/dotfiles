autoload -Uz reset

# () {
#     local min_tmout=$(( 24*3600 ))
#     # if TMOUT is set on some environment, extend it to 24 hours
#     [[ $TMOUT = <-> ]] && (( $TMOUT <= $min_tmout )) && export TMOUT=$(( $min_tmout ))
# }

# Try to remove stale zsh processes if kubectl-exec connection is broken
if [[ -n $KUBERNETES_SERVICE_HOST && $PPID -eq 0 && $SHLVL -eq 1 && -z $TMUX && -z $TMOUT ]]; then
    # logout if inactive for 10 minutes
    TMOUT=$(( 10 * 60 ))
fi
