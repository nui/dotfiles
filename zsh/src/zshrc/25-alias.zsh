# Aliases and interactive shell configuration
autoload -Uz cdd
autoload -Uz cde

# do not save 'cd' to history
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
if [[ -n $TMUX ]]; then
    alias ssenv=' tmux show-environment && eval $(tmux show-environment -s)'
fi

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
