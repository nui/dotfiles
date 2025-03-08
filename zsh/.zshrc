# This file is generated by merging all files under zsh/src/zshrc/
# It shouldn't be edit manually
() {
    local file
    for file ($ZDOTDIR/zshrc.pre.d/*.zsh(N)) source $file
}
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
autoload -Uz compinit
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -a -o tty,pid,%cpu,cmd k %cpu'
zstyle ':completion:*:(ssh|scp|sftp):*' hosts off
() {
    local cmd
    for cmd (dircolors) {
        (( ${+commands[$cmd]} )) && {
            eval "$($cmd -b)"
            zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
            break
        }
    }

    local -a completion_dir
    completion_dir=(
        /usr/share/zsh/vendor-completions
        $NMK_HOME/vendor/completion
    )
    # Try to add completion directories to fpath
    # if $fp not in $fpath and $fp does exists
    for fp in $completion_dir; do
        if [[ ${fpath[(ie)$fp]} -gt ${#fpath} && -d $fp ]]; then
            fpath+=$fp
        fi
    done
}
compinit

# Aliases and interactive shell configuration
autoload -Uz cdd
autoload -Uz cde

alias cd=' cd'
[[ $OSTYPE == linux* ]] && alias cp='cp --reflink=auto'
alias grep='grep --color=auto'
alias help=run-help
() {
    local -a ls_options
    local color

    local prog=ls
    local version=gnu

    if ((${+commands[lsd]})); then
        ls_options+=(--group-dirs first)
        if [[ $TERMINAL_EMULATOR = JetBrains-JediTerm ]]; then
            color="--color=never"
        fi
        alias la=" lsd $ls_options -lha"
        alias lh=" lsd $ls_options -lh"
        alias ls="lsd $ls_options"
    else
        case $OSTYPE in
            linux*) ;;
            darwin*)
                if (( ${+commands[gls]} )); then
                    prog=gls
                else
                    version=bsd
                fi
                ;;
            freebsd*) version=bsd ;;
        esac

        if [[ $version == gnu ]]; then
            ls_options+=--group-directories-first
            color='--color=auto'
        else
            color='-G'
        fi

        alias la=" command $prog $color $ls_options -lha"
        alias lh="command $prog $color $ls_options -lh"
        alias ls="command $prog $color"
    fi
}

autoload -Uz rf
autoload -Uz use-gpg-ssh-agent

# Productive Git aliases and functions
(( ${+commands[git]} )) && {
    autoload -Uz git-reset-to-remote-branch
    autoload -Uz grst
    alias gco=' git checkout'
    alias gd=' git diff'
    alias gds=' git diff --staged'
    alias grh=' git reset --hard'
    alias gs=' git status'
    # Use alternate screen in git log
    alias lol=" git log --oneline --decorate --graph --color=auto"
    alias gpr=' git pull --rebase'
    alias grrb=' git-reset-to-remote-branch'
}

# see https://dandavison.github.io/delta/environment-variables.html
(( ! ${+commands[delta]} )) && [[ -z $GIT_PAGER ]] && {
    export GIT_PAGER='less -+F -+X -c'
}

# vi = Vim without plugins
(( ${+commands[vi]} )) && {
    alias vi='env -u VIMINIT vi'
}

(( ${+commands[kubectl]} )) && {
    autoload -Uz k-node-shutdown-cleanup
    alias k-freepv="kubectl patch pv -p '{\"spec\":{\"claimRef\": null}}'"
    () {
        local template
        template='{{range .items}}{{$namespace:=.metadata.namespace}}{{range .spec.ports}}{{if .nodePort}}{{.nodePort}} name:{{.name}} protocol:{{.protocol}} port:{{.port}} targetPort:{{.targetPort}} namespace:{{$namespace}}{{"\n"}}{{end}}{{end}}{{end}}'
        alias k-get-nodeport="kubectl get svc -o go-template=${(q)template}"
    }
    k-list-nodeports() {
        local template
        template='{{range .items}}{{$namespace:=.metadata.namespace}}{{range .spec.ports}}{{if .nodePort}}{{.nodePort}}{{","}}{{.targetPort}}{{","}}{{.name}}{{","}}{{$namespace}}{{","}}{{.protocol}}{{"\n"}}{{end}}{{end}}{{end}}'
        kubectl get svc -o go-template="${template}" --all-namespaces $@ | sort | column -s, -t --table-name nodeport --table-columns NodePort,TargetPort,Name,Namespace,Protocol
    }
}

[[ $OSTYPE == linux* ]] && (( ${+commands[docker]} )) && {
    # Run docker as root
    # note: since docker client is stated by root, it will read configuration from ~root/.docker
    alias rdocker='sudo docker'
    (( ${+commands[rootlesskit]} )) && {
        alias rk='rootlesskit'
    }
}

[[ -n $EDITOR ]] && alias neo=$EDITOR

# on system root is main account
[[ "$UID" != 0 ]] && alias nmr='sudo -H -i /root/.nmk/bin/nmk'

# apply tmux session environment to running shell
alias ssenv=' eval $(tmux show-environment -s)'

# reset nvidia gpu
[[ $OSTYPE == linux* ]] && alias gpu-reload="sudo rmmod nvidia_uvm ; sudo modprobe nvidia_uvm"

if [[ $OSTYPE == darwin* ]]; then
    function chrome-app() {
        if [[ $# != 1 ]]; then
            echo "usage: $0 url"
            return 1
        fi
        open -a "Google Chrome" --new --args --app=$1
    }
elif (( ${+commands[kstart]} )); then
    function chrome-app() {
        if [[ $# != 1 ]]; then
            echo "usage: $0 url"
            return 1
        fi
        >/dev/null 2>&1 kstart google-chrome -- --app=$1
    }
fi

if [ -f /etc/alpine-release ]; then
    unalias cp
    unalias grep
    unalias ls
fi
() {
    # fix vendor zsh key binding
    local ubuntu_zshrc
    ubuntu_zshrc=$ZDOTDIR/ubuntu-etc-zsh-zshrc
    if ((_nmk_is_vendored_zsh)) && [[ -e $ubuntu_zshrc ]]; then
        . $ubuntu_zshrc
    fi
}

() {
    # see /etc/zsh/zshrc
    local -A key
    key=(
        CtrlL      "^L"
        CtrlR      "^R"
        CtrlS      "^S"
        CtrlZ      "^Z"

        # this is copy from /etc/zsh/zshrc
        BackSpace  "${terminfo[kbs]}"
        Home       "${terminfo[khome]}"
        End        "${terminfo[kend]}"
        Insert     "${terminfo[kich1]}"
        Delete     "${terminfo[kdch1]}"
        Up         "${terminfo[kcuu1]}"
        Down       "${terminfo[kcud1]}"
        Left       "${terminfo[kcub1]}"
        Right      "${terminfo[kcuf1]}"
        PageUp     "${terminfo[kpp]}"
        PageDown   "${terminfo[knp]}"
    )

    bind2maps() {
        local i sequence widget
        local -a maps

        while [[ "$1" != "--" ]]; do
            maps+=( "$1" )
            shift
        done
        shift

        sequence="${key[$1]}"
        widget="$2"

        [[ -z "$sequence" ]] && return 1

        for i in "${maps[@]}"; do
            bindkey -M "$i" "$sequence" "$widget"
        done
    }

    # use emacs keybindings
    bindkey -e

    if [[ -n $TMUX ]]; then
        # ^L to clear tmux history
        autoload -Uz nmk-tmux-clear-history && zle -N nmk-tmux-clear-history
        bind2maps emacs         -- CtrlL      nmk-tmux-clear-history
    fi
    # PageUp/PageDown do nothing
    bind2maps emacs             -- PageUp     redisplay
    bind2maps emacs             -- PageDown   redisplay
    # Search backwards and forwards with a pattern
    bind2maps emacs -- CtrlR history-incremental-pattern-search-backward
    bind2maps emacs -- CtrlS history-incremental-pattern-search-forward

    # Copied from ubuntu zshrc
    # This is probably useful for all places
    # I enable this for darwin only because that is where problem occur (especially when plugin keychron)
    if [[ $OSTYPE = darwin* ]]; then
        # bind2maps emacs             -- BackSpace   backward-delete-char
        # bind2maps       viins       -- BackSpace   vi-backward-delete-char
        # bind2maps             vicmd -- BackSpace   vi-backward-char
        bind2maps emacs             -- Home        beginning-of-line
        bind2maps       viins vicmd -- Home        vi-beginning-of-line
        bind2maps emacs             -- End         end-of-line
        bind2maps       viins vicmd -- End         vi-end-of-line
        # I don't think mapping for Insert work without extra effort, I just want to keep it here.
        bind2maps emacs viins       -- Insert      overwrite-mode
        bind2maps             vicmd -- Insert      vi-insert
        bind2maps emacs             -- Delete      delete-char
        bind2maps       viins vicmd -- Delete      vi-delete-char
        # bind2maps emacs viins vicmd -- Up          up-line-or-history
        # bind2maps emacs viins vicmd -- Down        down-line-or-history
        # bind2maps emacs             -- Left        backward-char
        # bind2maps       viins vicmd -- Left        vi-backward-char
        # bind2maps emacs             -- Right       forward-char
        # bind2maps       viins vicmd -- Right       vi-forward-char
    fi

    bindkey '^X^E' edit-command-line
    autoload -Uz fancy-ctrl-z && zle -N fancy-ctrl-z
    bind2maps emacs -- CtrlZ fancy-ctrl-z

    unfunction bind2maps
}
autoload -Uz reset

() {
    local min_tmout=$(( 24*3600 ))
    # if TMOUT is set on some environment, extend it to 24 hours
    [[ $TMOUT = <-> ]] && (( $TMOUT <= $min_tmout )) && export TMOUT=$(( $min_tmout ))
}

if [[ -n $TMUX ]] && [[ -n $KUBERNETES_PORT ]]; then
k-detach-other-clients-sighup-parent() {
    set -ex
    tmux detach-client -aP
}
fi
# Don't display git branch symbol if terminal does not support 256 colors
(( ${+commands[tput]} )) && (( $(command tput colors) < 256 )) && horizontal_branch_symbol=

prompt horizontal

# Hide user and host in prompt if NMK_DEVELOPMENT is true by default,
# this is not apply to zsh in ssh session
[[ $NMK_DEVELOPMENT == true && -z $SSH_TTY ]] && horizontal[userhost]=0

# Change prompt color on remote session
if [[ -n $SSH_TTY || $SUDO_USER == ssm-user ]]; then
    if [[ $horizontal[base_color] == $horizontal_default[base_color] ]]; then
        horizontal[base_color]=magenta
    fi
fi

_nmk_precmd_functions=()
_nmk_preexec_functions=()

_nmk-kubectl-precmd() {
    if [[ -n $KUBECTL_CONTEXT ]]; then
        alias kubectl="kubectl --context=$KUBECTL_CONTEXT"
    fi
}

_nmk-kubectl-preexec() {
    if [[ -n $KUBECTL_CONTEXT ]]; then
        unalias kubectl
    fi
}

typeset -g _nmk_update_ssh_socket_last_check=$EPOCHSECONDS
_nmk-update-ssh-socket() {
    [[ -n $SSH_AUTH_SOCK && ! -S $SSH_AUTH_SOCK ]] || (( $EPOCHSECONDS - $_nmk_update_ssh_socket_last_check > 300 )) && {
        eval $(tmux show-environment -s)
    }
    _nmk_update_ssh_socket_last_check=$EPOCHSECONDS
}

(( ${+commands[kubectl]} )) && {
    _nmk_precmd_functions+=_nmk-kubectl-precmd
    _nmk_preexec_functions+=_nmk-kubectl-preexec
}

[[ -n $TMUX && -n $SSH_CONNECTION && -S $SSH_AUTH_SOCK ]] && {
    _nmk_precmd_functions+=_nmk-update-ssh-socket
}

_nmk_precmd() {
    local hook
    for hook in $_nmk_precmd_functions; do
        $hook
    done
}

_nmk_preexec() {
    local hook
    for hook in $_nmk_preexec_functions; do
        $hook
    done
}

add-zsh-hook precmd  _nmk_precmd
add-zsh-hook preexec _nmk_preexec
# Detect & load version managers
() {
    typeset -a managers
    # Detect jenv
    (( ${+commands[jenv]} )) && {
        managers+=(jenv)
        function init-jenv {
            eval "$(jenv init -)"
        }
    }
    # Detect nvm
    # nvm recommends git checkout not brew
    export NVM_DIR=${NVM_DIR:-$HOME/.nvm}
    [[ -e $NVM_DIR/nvm.sh ]] && {
        managers+=(nvm)
        function init-nvm {
            local cmd
            cmd='source $NVM_DIR/nvm.sh'
            # avoid calling `nvm use` again
            (( ${+NVM_BIN} )) && cmd+=' --no-use'
            eval "$cmd"
        }
    }
    # Detect pyenv, both by brew or git
    (( ${+commands[pyenv]} )) && {
        managers+=(pyenv)
        function init-pyenv {
            integer has_virtualenv
            typeset -a pyenv_commands
            pyenv_commands=($(pyenv commands))
            [[ ${pyenv_commands[(r)virtualenv]} == virtualenv ]] \
                && ((has_virtualenv = 1))
            eval "$(pyenv init --path)"
            if (( ${+PYENV_SHELL} )); then
                eval "$(pyenv init - --no-rehash zsh)"
            else
                eval "$(pyenv init - zsh)"
            fi
            if (( has_virtualenv )); then
                # see https://github.com/pyenv/pyenv-virtualenv#activate-virtualenv
                # eval "$(pyenv virtualenv-init - zsh)"
                function virtualenv-init {
                    eval "$(pyenv virtualenv-init - zsh)"
                    unfunction virtualenv-init
                }
            fi
        }
    }
    # Detect rbenv, both by brew or git
    (( ${+commands[rbenv]} )) && {
        managers+=(rbenv)
        function init-rbenv {
            if (( ${+RBENV_SHELL} )); then
                eval "$(rbenv init - --no-rehash zsh)"
            else
                eval "$(rbenv init - zsh)"
            fi
        }
    }
    # set default value if nmk_version_managers is unset
    (( ! ${+nmk_version_managers} )) && {
        typeset -ga nmk_version_managers
        nmk_version_managers=($managers)
    }
    local manager
    for manager in $nmk_version_managers; do
        case $manager in
            jenv ) init-jenv; unfunction init-jenv ;;
            nvm ) init-nvm; unfunction init-nvm ;;
            pyenv ) init-pyenv; unfunction init-pyenv ;;
            rbenv ) init-rbenv; unfunction init-rbenv ;;
        esac
    done
}
[[ -e /etc/zsh_command_not_found ]] && source /etc/zsh_command_not_found
typeset -U path
() {
    local file
    for file ($ZDOTDIR/zshrc.extra.d/*.zsh(N)) source $file
}
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
