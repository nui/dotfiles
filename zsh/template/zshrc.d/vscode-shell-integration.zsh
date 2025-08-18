() {
    setopt localoptions noshwordsplit

    [[ $TERM_PROGRAM == vscode ]] || return 0
    local cache_dir
    local cache_file
    local shell_path
    cache_dir=$NMK_HOME/.cache
    if [[ $REMOTE_CONTAINERS = true ]];then
        cache_file=$cache_dir/vscode-shell-integration-path.container.zsh
    else
        cache_file=$cache_dir/vscode-shell-integration-path.host.zsh
    fi
    if [[ -e $cache_file ]]; then
        source $cache_file
    else
        shell_path=$(code --locate-shell-integration-path zsh 2>/dev/null)
        [[ -e $shell_path ]] && {
            mkdir -p $cache_dir
            # cache it
            rm -f $cache_file
            ln -sf $shell_path $cache_file
            source $shell_path
        }
    fi
}
