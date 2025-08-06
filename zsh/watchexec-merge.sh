#!/bin/zsh

cd ${0:a:h}

watchexec -f 'src/zprofile/*.zsh' 'cat src/zprofile/*.zsh > .zprofile.merged.zsh' &
watchexec -f 'src/zshrc/*.zsh' 'cat src/zshrc/*.zsh > .zshrc'
