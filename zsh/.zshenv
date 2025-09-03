if [[ $NMK_ZSH_GLOBAL_RCS == "0" ]]; then
    unsetopt GLOBAL_RCS
fi

function {
    setopt localoptions noshwordsplit histsubstpattern

    typeset -g _nmk_is_vendored_zsh=0
    local fp
    for fp in $fpath; do
        if [[ $fp == /nmk-vendor* ]]; then
            _nmk_is_vendored_zsh=1
            break
        fi
    done

    (( $_nmk_is_vendored_zsh )) && {
        fpath=(
            # Fix hard-coded path of vendored zsh.
            # When we compile zsh, installation path is set to /nmk-vendor.
            # We have to change fpath at runtime to match actual installation directory.
            ${fpath:s|#/nmk-vendor|${NMK_HOME}/vendor|}
        )
    }

    fpath=(
        $ZDOTDIR/functions
        $ZDOTDIR/fpath
        # My completion
        $ZDOTDIR/completion
        # My theme
        $ZDOTDIR/themes
        # Plugin completion
        $ZDOTDIR/plugins/zsh-completions/src

        ${fpath[@]}
    )

    typeset -a additional_fpath

    case $OSTYPE in
        linux*)
            additional_fpath=(
                /usr/share/zsh/vendor-completions
                /usr/share/zsh/vendor-functions
            )
            ;;
        darwin*)
            additional_fpath=(
                /opt/homebrew/share/zsh/site-functions
            )
            ;;
        *)
            ;;
    esac

    local dir
    for dir in $additional_fpath; do
        if [[ ${fpath[(r)$dir]} != $dir && -d $dir ]]; then
            fpath+=$dir
        fi
    done
}

if [[ -e $ZDOTDIR/zshenv.extra ]]; then
    source $ZDOTDIR/zshenv.extra
fi

