docker-getip() {
    local container=$1
    docker inspect "$container" --format "{{range .NetworkSettings.Networks}}{{.IPAddress}}\n{{end}}"
}

dockermac() {
    [[ $OSTYPE == darwin* ]] || {
        echo 1>&2 "notice: this command should only be run under macOS"
        return
    }
    open -j -g -a Docker.app
}

alias dc='docker compose'
alias dps="docker ps --format 'table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Image}}'"
