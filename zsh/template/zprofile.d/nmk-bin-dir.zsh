() {
    # Initialize path if not start from our launcher
    if [[ ! -e $NMK_LAUNCHER_PATH ]]; then
        local dir
        local name
        for name in local/bin devbin bin; do
            dir=$NMK_HOME/$name
            # if $dir is not in path array
            if [[ ${path[(Ie)$dir]} -eq 0 ]]; then
                path=($dir $path)
            fi
        done
    fi
}
