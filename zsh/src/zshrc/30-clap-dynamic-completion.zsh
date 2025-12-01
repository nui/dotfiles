# set default value if nmk_clap_dynamic_completions is unset
(( ! ${+nmk_clap_dynamic_completions} )) && {
    typeset -ga nmk_clap_dynamic_completions
    nmk_clap_dynamic_completions=(nmk nmkup)
}

() {
    local file
    local name
    for name ($nmk_clap_dynamic_completions) {
        (( ${+commands[$name]} )) && {
            file=$ZDOTDIR/zshrc.clap-dynamic-completion.d/${name}.zsh
            # we need zsh-defer to make dynamic completion work on linux
            # no idea why it doesn't work
            [[ -e $file ]] && zsh-defer source $file
        }
    }
}

