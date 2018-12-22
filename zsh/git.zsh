alias gfa="git-allrepos -0 | xargs -0 -n1 -P10 -I\% bash -c '(cd %; git fetch --prune)'"
alias gmall="git-allrepos -0 | xargs -0 -n1 -I\% bash -c '(cd %; echo %; git merge --ff-only; echo)'"
alias gf="git fetch --prune"
