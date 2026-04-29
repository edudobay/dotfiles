#!/usr/bin/env zsh

[[ ! -f ~/.zfunc/_jj ]] \
    && type jj &>/dev/null \
    && mkdir -p ~/.zfunc \
    && jj util completion zsh > ~/.zfunc/_jj

