() {
    local file
    for file ($ZDOTDIR/zshrc.pre.d/*.zsh(N)) {
        [[ -e $file ]] && source $file
    }
}

