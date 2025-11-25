() {
    local file
    for file ($ZDOTDIR/zshrc.clap-dynamic-completion.d/*.zsh(N)) {
        # we need zsh-defer here to make it works on linux
        [[ -e $file ]] && zsh-defer source $file
    }
}
