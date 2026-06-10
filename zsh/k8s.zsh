k8cfg() {
    local kubedir=~/.kube config_file _KUBECONFIG
    if [[ $1 == :* ]]; then
        local search_prefix=${1#:} config_files
        shift
        if [[ -f $kubedir/${search_prefix}.config ]]; then
            _KUBECONFIG=$kubedir/${search_prefix}.config  # exact match
        else
            config_files=($(ls $kubedir/${search_prefix}*config))
            if [[ ${#config_files} -eq 1 ]]; then
                _KUBECONFIG=${config_files[1]}
            else
                echo "${#config_files} matches found for '${search_prefix}'; expected exactly 1" 1>&2
                return 1
            fi
        fi
    else
        _KUBECONFIG=$(ls $kubedir/*config | fzf)
        if [[ ! -n $_KUBECONFIG ]]; then
            echo "no config files found in ~/.kube" 1>&2
            return 1
        fi
    fi

    echo "Using KUBECONFIG=$_KUBECONFIG"

    if [[ $# -gt 0 ]]; then
        KUBECONFIG=$_KUBECONFIG "$@"
        return
    fi

    export KUBECONFIG=$_KUBECONFIG
}
