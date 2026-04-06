k8cfg() {
    config_file=$(ls ~/.kube/*config | fzf)
    [[ -n $config_file ]] || return 1

    export KUBECONFIG=$config_file
    echo "Using KUBECONFIG=$KUBECONFIG"
}
