if [[ $NMK_ZSH_GLOBAL_RCS == "0" ]]; then
    unsetopt GLOBAL_RCS
fi

() {
    setopt localoptions histsubstpattern

    typeset -g _nmk_is_vendored_zsh=0
    for p in $fpath; do
        if [[ $p == /nmk-vendor* ]]; then
            _nmk_is_vendored_zsh=1
            break
        fi
    done

    fpath=(
        $ZDOTDIR/functions
        $ZDOTDIR/fpath
        # My completion
        $ZDOTDIR/completion
        # My theme
        $ZDOTDIR/themes
        # Plugin completion
        $ZDOTDIR/plugins/zsh-completions/src

        # Fix hard-coded path of vendored zsh.
        # When we compile zsh, installation path is set to /nmk-vendor.
        # We have to change fpath at runtime to match actual installation directory.
        ${fpath:s|#/nmk-vendor|${NMK_HOME}/vendor|}
    )
    typeset -a additional_fpath
    additional_fpath=(
        /opt/homebrew/share/zsh/site-functions
        /usr/share/zsh/vendor-completions
        /usr/share/zsh/vendor-functions
    )
    for dir in $additional_fpath; do
        if [[ -d $dir && ${fpath[(r)$dir]} != $dir ]]; then
            fpath+=$dir
        fi
    done
}


if [[ -e $ZDOTDIR/zshenv.extra ]]; then
    source $ZDOTDIR/zshenv.extra
fi

