() {
    # see /etc/zsh/zshrc
    local -A key
    key=(
        CtrlL      "^L"
        CtrlR      "^R"
        CtrlS      "^S"
        CtrlZ      "^Z"

        # this is copy from /etc/zsh/zshrc
        BackSpace  "${terminfo[kbs]}"
        Home       "${terminfo[khome]}"
        End        "${terminfo[kend]}"
        Insert     "${terminfo[kich1]}"
        Delete     "${terminfo[kdch1]}"
        Up         "${terminfo[kcuu1]}"
        Down       "${terminfo[kcud1]}"
        Left       "${terminfo[kcub1]}"
        Right      "${terminfo[kcuf1]}"
        PageUp     "${terminfo[kpp]}"
        PageDown   "${terminfo[knp]}"
    )

    bind2maps() {
        local i sequence widget
        local -a maps

        while [[ "$1" != "--" ]]; do
            maps+=( "$1" )
            shift
        done
        shift

        sequence="${key[$1]}"
        widget="$2"

        [[ -z "$sequence" ]] && return 1

        for i in "${maps[@]}"; do
            bindkey -M "$i" "$sequence" "$widget"
        done
    }

    # use emacs keybindings
    bindkey -e

    if [[ -n $TMUX ]]; then
        # ^L to clear tmux history
        autoload -Uz nmk-tmux-clear-history && zle -N nmk-tmux-clear-history
        bind2maps emacs         -- CtrlL      nmk-tmux-clear-history
    fi
    # PageUp/PageDown do nothing
    bind2maps emacs             -- PageUp     redisplay
    bind2maps emacs             -- PageDown   redisplay
    # Search backwards and forwards with a pattern
    bind2maps emacs -- CtrlR history-incremental-pattern-search-backward
    bind2maps emacs -- CtrlS history-incremental-pattern-search-forward

    # Copied from ubuntu zshrc
    # This is probably useful for all places
    # I enable this for darwin only because that is where problem occur (especially when plugin keychron)
    if [[ $OSTYPE = darwin* ]]; then
        # bind2maps emacs             -- BackSpace   backward-delete-char
        # bind2maps       viins       -- BackSpace   vi-backward-delete-char
        # bind2maps             vicmd -- BackSpace   vi-backward-char
        bind2maps emacs             -- Home        beginning-of-line
        bind2maps       viins vicmd -- Home        vi-beginning-of-line
        bind2maps emacs             -- End         end-of-line
        bind2maps       viins vicmd -- End         vi-end-of-line
        # I don't think mapping for Insert work without extra effort, I just want to keep it here.
        bind2maps emacs viins       -- Insert      overwrite-mode
        bind2maps             vicmd -- Insert      vi-insert
        bind2maps emacs             -- Delete      delete-char
        bind2maps       viins vicmd -- Delete      vi-delete-char
        # bind2maps emacs viins vicmd -- Up          up-line-or-history
        # bind2maps emacs viins vicmd -- Down        down-line-or-history
        # bind2maps emacs             -- Left        backward-char
        # bind2maps       viins vicmd -- Left        vi-backward-char
        # bind2maps emacs             -- Right       forward-char
        # bind2maps       viins vicmd -- Right       vi-forward-char
    fi

    bindkey '^X^E' edit-command-line
    autoload -Uz fancy-ctrl-z && zle -N fancy-ctrl-z
    bind2maps emacs -- CtrlZ fancy-ctrl-z

    unfunction bind2maps
}
