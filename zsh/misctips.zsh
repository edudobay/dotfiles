# These tips were gathered from
# http://chneukirchen.org/blog/archive/2011/02/10-more-zsh-tricks-you-may-not-know.html

# Force file name completion on C-x TAB, Shift-TAB
zle -C complete-files complete-word _generic
zstyle ':completion:complete-files:*' completer _files
bindkey "^X^I" complete-files
bindkey "^[[Z" complete-files

# Move to where arguments belong.
after-first-word() {
   zle beginning-of-line
   zle forward-word
}
zle -N after-first-word
bindkey "^X1" after-first-word

