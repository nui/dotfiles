# Initialize required variables if not start from our launcher
#
# NMK_LAUNCHER_PATH is set by the launcher
if [[ ! -e $NMK_LAUNCHER_PATH ]]; then
    # This block is reachable because the launcher has never been run
    #
    # we setup minimum required variables of dotfiles project
    (( ! ${+NMK_HOME} )) && {
        # In our setup, ZDOTDIR always under NMK_HOME
        # :A modifier is used to follow symlink correctly
        export NMK_HOME=${ZDOTDIR:A:h}
    }
    (( ! ${+VIMINIT} )) && export VIMINIT="source ${NMK_HOME:q}/vim/init.vim"
fi

