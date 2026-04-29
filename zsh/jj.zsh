# Jujutsu (VCS) - https://docs.jj-vcs.dev/latest/

# adapted from https://lobste.rs/s/exlogg/jjj
_fzf_insert_jj_commit() {
  local selected rev

  selected=$(
    jj log -r 'all()' -T builtin_log_oneline --color=always \
      | fzf \
          --min-height=15 \
          --cycle \
          --ansi \
          --prompt "jj rev> "
  )

  rev=$(echo "$selected" | awk '{for(i=1;i<=NF;i++) if(length($i)>=7){print $i; exit}}')

  LBUFFER="${LBUFFER}${rev}"
}
zle -N _fzf_insert_jj_commit
bindkey '^Xj' _fzf_insert_jj_commit
