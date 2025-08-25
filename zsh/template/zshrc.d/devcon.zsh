() {
    local container_name=$DEVCON_CONTAINER_NAME
    [[ -n $container_name ]] && {
        typeset -g horizontal_hostname
        horizontal_hostname=${horizontal_hostname:-$container_name}
    }
}

