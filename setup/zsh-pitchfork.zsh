#!/usr/bin/env zsh

# Pitchfork - https://pitchfork.en.dev/installation.html

[[ ! -f ~/.zfunc/_pitchfork ]] \
    && type pitchfork &>/dev/null \
    && mkdir -p ~/.zfunc \
    && pitchfork completion zsh > ~/.zfunc/_pitchfork
