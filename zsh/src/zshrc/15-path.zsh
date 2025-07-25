if [[ $OSTYPE == darwin* ]] && [[ $TERM_PROGRAM == vscode ]]; then
    # VSCode on MacOs move /usr/local/bin to the front of path.
    # We install release build at that location as a fallback version.

    # We put $NMK_HOME/bin to the front of path to fix this annoying issue.
    path=($NMK_HOME/bin $path)
fi

