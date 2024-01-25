# macOS user dirs
# (N) = NULL_GLOB
for dir in ~/Library/Python/3.*/bin(N); do
    [[ -d "$dir" ]] || continue
    path+=("$dir")
done
