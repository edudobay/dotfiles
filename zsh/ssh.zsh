# Tip by https://wiki.archlinux.org/title/SSH_keys#SSH_agents
if [ $(pgrep -u $USER ssh-agent | wc -l) -eq 0 ]; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! $SSH_AUTH_SOCK && -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
