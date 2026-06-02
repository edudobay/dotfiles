_cdk_is_root() {
  [[ -d $1/.git ]]
}

# cdk: change directory to project root; "k" stands for "above" as in the vim motion
cdk() {
  local dir=$PWD target
  if _cdk_is_root $dir; then
    return 0
  fi
  while [[ $dir != / ]]; do
    dir=$(dirname $dir)
    if _cdk_is_root $dir; then
      target=$dir
      break
    fi
  done
  if [[ -z $target ]]; then
    echo "cdk: no project root found" >&2
    return 1
  fi
  echo "chdir to $target (was: $PWD)"
  cd $target
}