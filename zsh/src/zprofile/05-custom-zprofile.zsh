if [[ -e $ZDOTDIR/zprofile ]]; then
    source $ZDOTDIR/zprofile
fi

() {
    local file
    for file ($ZDOTDIR/zprofile.d/*.zsh(N)) {
        [[ -e $file ]] && source $file
    }
}

