() {
    local file
    for file ($ZDOTDIR/zshrc.extra.d/*.zsh(N)) {
        [[ -e $file ]] && source $file
    }
}
