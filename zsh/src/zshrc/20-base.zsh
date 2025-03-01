autoload -Uz edit-command-line && zle -N edit-command-line
autoload -Uz promptinit && promptinit
autoload -Uz async && async

setopt AUTO_PUSHD
setopt DVORAK
setopt EXTENDED_GLOB
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS  # allow copy paste command with comment
setopt PUSHD_MINUS
setopt SHARE_HISTORY

# Release ^S for use in history-incremental-pattern-search-forward
unsetopt FLOW_CONTROL
stty -ixon # vim in remote ssh connection need this

# Respect existing HISTFILE
HISTFILE="${HISTFILE:-${ZDOTDIR}/.zsh_history}"
HISTSIZE=5000
SAVEHIST=$HISTSIZE
