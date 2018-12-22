#!/bin/zsh
i=1
while [[ $i -le $# ]]; do
    echo "[$i] ${argv[$i]}"
    let i++
done
