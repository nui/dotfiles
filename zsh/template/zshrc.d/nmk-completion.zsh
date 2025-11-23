init-nmk-completion() {
    (( ${+commands[nmk]} )) && {
        eval "$(COMPLETE=zsh nmk)"
    }
}

zsh-defer -c 'init-nmk-completion; unfunction init-nmk-completion' 

