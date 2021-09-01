command_not_found_handler() {
    cmd=$1
    if [[ $cmd = ${cmd:u} ]]; then
        echo 'PLEASE STOP SCREAMING!!!1' >&2
    fi
    echo "$cmd: command not found" >&2
    return 127
}
