function yay()
{
    # Disable 'quit if one screen', because this is annoying when displaying multiple diffs for AUR builds
    LESS='-R' command yay "$@"
}
