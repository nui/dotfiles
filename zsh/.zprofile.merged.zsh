# Initialize required variables if not start from our launcher
if [[ ! -e $NMK_LAUNCHER_PATH ]]; then
    # Why this block is reached?
    #   - macOS shell (macOS doesn't start login shell on login)
    #   - ssh login to linux that doesn't call launcher
    #   - newly setup linux

    (( ! ${+NMK_HOME} )) && {
        # In our setup, ZDOTDIR always under NMK_HOME
        # :A modifier is used to follow symlink correctly
        export NMK_HOME=${ZDOTDIR:A:h}
    }
    (( ! ${+VIMINIT} )) && export VIMINIT="source ${NMK_HOME:q}/vim/init.vim"
fi

if [[ -e $ZDOTDIR/zprofile ]]; then
    source $ZDOTDIR/zprofile
fi

() {
    local file
    for file ($ZDOTDIR/zprofile.d/*.zsh(N)) {
        [[ -e $file ]] && source $file
    }
}

