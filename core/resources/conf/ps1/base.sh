# To skip changing changing PS1 to PS1_BASE, paste
#   PS1_BASE="${PS1}"
# before the current script is sourced, or
#   PS1="${PS1_ORIGIN}"
# after the current script is sourced
_iife_ps1_base() {
  unset _iife_ps1_base

  local is_root=false; [[ $(id -u) -eq 0 ]] && is_root=true
  # define colors
  local prefix_color=32; ${is_root} && prefix_color=36
  # format PS1
  local prefix; prefix="$(
    printf '\[\033[01;'${prefix_color}'m\]%s %s\[\033[00m\]' '\u@\h' '\w'
  )"

  PS1_ORIGIN="${PS1_ORIGIN:-${PS1}}"
  PS1_BASE="${PS1_BASE:-$(printf '[%s] ' "${prefix}")}"
  PS1="${PS1_BASE}"
}; _iife_ps1_base
