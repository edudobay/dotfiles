## Changing pane title

**Manually:**
```bash
tmux select-pane -T "my title"
# or from inside tmux:
printf '\033]2;my title\033\\'
```

**Programmatically (from your shell):**

In zsh, add to your `~/.zshrc`:
```zsh
# Set pane title to current directory (or whatever you want)
precmd() { printf '\033]2;%s\033\\' "${PWD/#$HOME/~}" }
```

Or to show the running command:
```zsh
preexec() { printf '\033]2;%s\033\\' "$1" }
precmd() { printf '\033]2;%s\033\\' "${PWD/#$HOME/~}" }
```
`preexec` fires before a command runs (sets title to the command), `precmd` fires after it returns (resets to the directory).

**From a script/program:**
```bash
printf '\033]2;my title\033\\'
# The escape sequence is: ESC ] 2 ; <title> ESC \
```

The `2` sets the pane/window title. Some terminals also accept `0` (sets both icon name and title) or `1` (icon name only) — tmux treats them the same.
