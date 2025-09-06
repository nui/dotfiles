if [[ $OSTYPE == darwin* ]] && [[ $TERM_PROGRAM == vscode ]]; then
    # vscode on macOS move /usr/local/bin to the front of path.
    # We put $NMK_HOME/bin to the front of path to fix this annoying issue.
    path=($NMK_HOME/bin $path)
fi

