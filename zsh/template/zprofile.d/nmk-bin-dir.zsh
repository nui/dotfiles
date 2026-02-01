() {
    # Initialize path if not start from our launcher
    if [[ -z $NMK_LAUNCHER_PATH ]]; then
        local -a bin_dirs
        local dir
        local name
        for name in bin devbin; do
            dir=$NMK_HOME/$name
            # If $dir is not present in the path array
            if [[ ${path[(Ie)$dir]} -eq 0 ]]; then
                bin_dirs+=($dir)
            fi
        done
        for name in local/bin; do
            dir=$NMK_HOME/$name
            # If $dir is not present in the path array and it does exist.
            if [[ ${path[(Ie)$dir]} -eq 0 && -d $dir ]]; then
                bin_dirs+=($dir)
            fi
        done
        path=($bin_dirs $path)
    fi
}

