# Auto-completion
# ---------------
[[ $- == *i* ]] && . "{{ etc_dir }}/completion.bash" 2> /dev/null

# Key bindings
# ------------
. "{{ etc_dir }}/key-bindings.bash" 2> /dev/null

__iife() {
  local -a opts

  opts+=(--height '100%')
  opts+=(--border)
  opts+=(--history-size 999999)
  # https://github.com/junegunn/fzf/issues/577#issuecomment-225953097
  opts+=(--preview "'echo {}'" --bind ctrl-p:toggle-preview)
  opts+=(--preview-window down:50%:wrap)

  [[ -n "${FZF_DEFAULT_OPTS}" ]] && export FZF_DEFAULT_OPTS
  FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+ }$(printf -- '%s ' "${opts[@]}" | sed -E 's/\s+$//')"
}; __iife; unset __iife
