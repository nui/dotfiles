# exec into container using docker exec over ssh

```zsh
alias connect-xxx='DOCKER_CLI_HINTS=false docker -H ssh://remote-ssh-server exec -w /home/user -i -t container_name .nmk/login.sh -2'
```