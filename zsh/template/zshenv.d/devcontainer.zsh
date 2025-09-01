# conditionally set ZDOTDIR if DEVCON_<username>_ZDOTDIR is set
# used in vscode devcontainer where we don't want to set global ZDOTDIR
() {
    setopt localoptions noshwordsplit
    local zdotdir_env="DEVCON_${(U)USERNAME}_ZDOTDIR"
    # The "-z $ZDOTDIR" check is necessary, to prevent recursively source itself.
    if [[ -o login && -z $ZDOTDIR && ${(P)zdotdir_env+set} = set ]]; then
        local zdotdir=${(P)zdotdir_env}
        if [[ -d $zdotdir ]]; then
            export ZDOTDIR=$zdotdir
            source $ZDOTDIR/.zshenv
        fi
    fi
}
