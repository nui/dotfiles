() {
    # Initialize path if not start from our launcher
    if [[ ! -e $NMK_LAUNCHER_PATH ]]; then
        local -a bin_dirs
        local dir
        local name
        bin_dirs=(bin devbin local/bin)
        # Oa = reverse order
        for name in ${(Oa)bin_dirs}; do
            dir=$NMK_HOME/$name
            # If $dir is not present in the path array and it does exist.
            if [[ ${path[(Ie)$dir]} -eq 0 && -d $dir ]]; then
                path=($dir $path)
            fi
        done
    fi
}
