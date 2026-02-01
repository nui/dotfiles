#!/bin/zsh

set -e

GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"

(
    cd $GIT_ROOT_DIR
    watchexec --shell=none \
        -f 'zsh/src/zprofile/*.zsh' \
        -f 'zsh/src/zshrc/*.zsh' \
        .githooks/merge-zsh-config
)

