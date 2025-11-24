() {
    # fix vendor zsh key binding
    local ubuntu_zshrc
    ubuntu_zshrc=$ZDOTDIR/ubuntu-etc-zsh-zshrc
    if ((_nmk_is_vendored_zsh)) && [[ -e $ubuntu_zshrc ]]; then
        . $ubuntu_zshrc
    fi
}

