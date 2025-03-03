#!/bin/zsh

cd ${0:a:h}

exec watchexec -f 'src/zshrc/*.zsh' 'cat src/zshrc/*.zsh > .zshrc'
