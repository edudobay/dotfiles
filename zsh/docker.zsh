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

DOCKER_PS_FORMAT="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Command}}"

_docker_ps() {
    local has_format=0
    local args=()
    local args_format=()
    local curr_arg
    for arg; do
        if [[ "$curr_arg" == --format ]]; then
            if [[ "$arg" != standard ]]; then
                args_format+=("$arg")
                args+=("${args_format[@]}")
            fi
            args_format=()
            continue
        fi

        if [[ "$arg" = --format ]]; then
            has_format=1
            curr_arg="$arg"
            args_format=("$arg")
            continue
        fi

        if [[ "$arg" = --format=* ]]; then
            has_format=1
            if [[ "$arg" != --format=standard ]]; then
                args+=("$arg")
            fi
            continue
        fi

        args+=("$arg")
    done

    if [[ $has_format = 0 ]]; then
        args+=(--format "$DOCKER_PS_FORMAT")
    fi

    command docker container ls "${args[@]}"
}

docker() {
    local args1="${1-}"
    local args2="${1-} ${2-}"

    case "$args1" in
        ps)
            shift; _docker_ps "$@"; return ;;
        *) ;;
    esac

    case "$args2" in
        'container ls'|'container ps'|'container list')
            shift 2; _docker_ps "$@"; return ;;
        *) ;;
    esac

    command docker "$@"
}

alias dc='docker compose'
alias dps="docker ps --format 'table {{.Names}}\t{{.ID}}\t{{.Status}}\t{{.Image}}'"
