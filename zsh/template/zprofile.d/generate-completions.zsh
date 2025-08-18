if (( ${+commands[docker]} )); then
    docker completion zsh > "$ZDOTDIR/completion/_docker"
fi
