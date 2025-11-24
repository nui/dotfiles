() {
    local file
    for file ($ZDOTDIR/zshrc.clap-dynamic-completion.d/*.zsh(N)) {
        [[ -e $file ]] && source $file
    }
}
