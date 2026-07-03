# mix of: crcandy, af-magic, and some other customizations

optional_user_and_host() {
   if [[ -n $SSH_TTY ]]; then
      print -n '%B%F{green}%n@%m%f%b '
   fi
}

prompt_exit_line() {
   local code=$?
   if (( code != 0 )); then
      PROMPT_EXIT_LINE="%F{124}(${code})%f"$'\n'
   else
      PROMPT_EXIT_LINE=""
   fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_exit_line

PROMPT='${PROMPT_EXIT_LINE}%F{237}${(l.$COLUMNS..-.)}%f
$(optional_user_and_host)%F{032}%~%f$(git_prompt_info)$(git_prompt_status)
%F{105}->%f %F{105}%#%f '

ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%F{239}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%f"

ZSH_THEME_GIT_PROMPT_PREFIX=" %F{075}(%F{078}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{075})%f"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%} ✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[yellow]%} ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%} ═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%} ✱"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[blue]%} ↑"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[blue]%} ↓"
