# macOS user dirs
for dir in ~/Library/Python/3.*/bin; do
    [[ -d "$dir" ]] || continue
    path+=("$dir")
done
