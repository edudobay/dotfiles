
PROMPT='%F{101}%1~$(git_prompt_info)$(git_prompt_status)%(?:%F{243}:%{%F{197}%}) %% %{$reset_color%}'
RPROMPT='$(git_prompt_short_sha)  %F{243}%*%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%F{239}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%f"

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[cyan]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
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

