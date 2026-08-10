_cdk_is_root() {
  [[ -d $1/.git ]]
}

project_root() {
  local dir=$1 root
  [[ -n "$dir" ]] || dir=$PWD
  if _cdk_is_root "$dir"; then
    echo "$dir"
    return 0
  fi
  dir=$(realpath "$dir")
  while [[ $dir != / ]]; do
    dir=$(dirname "$dir")
    if _cdk_is_root "$dir"; then
      root=$dir
      break
    fi
  done
  if [[ -z $root ]]; then
    echo "no project root found" >&2
    return 1
  fi
  echo "$root"
}

# cdk: change directory to project root; "k" stands for "above" as in the vim motion
cdk() {
  local dir=$PWD target
  target=$(project_root "$dir") 2>/dev/null
  if [[ -z $target ]]; then
    echo "cdk: no project root found" >&2
    return 1
  fi
  echo "chdir to $target (was: $PWD)"
  cd "$target"
}
