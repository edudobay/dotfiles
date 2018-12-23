# Useful for debugging and investigating shell rules on the fly.
params() {
  local i=1
  while [[ $# -gt 0 ]]; do
    echo "[$i] $1"
    let i++
    shift
  done
}
