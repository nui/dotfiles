if ((${+commands[aws_completer]})); then
    autoload bashcompinit && bashcompinit
    autoload -Uz compinit && compinit
    complete -C ${commands[aws_completer]} aws
fi
