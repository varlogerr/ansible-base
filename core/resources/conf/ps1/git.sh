# To skip changing changing PS1 to PS1_GIT, paste
#   PS1_GIT="${PS1}"
# before the current script is sourced, or
#   PS1="${PS1_ORIGIN}"
# after the current script is sourced
_iife_ps1_git() {
  unset _iife_ps1_git

  local is_root=false; [[ $(id -u) -eq 0 ]] && is_root=true
  # define colors
  local prefix_color=32; ${is_root} && prefix_color=36
  local branch_color=33; ${is_root} && branch_color=33
  # format PS1
  local prefix; prefix="$(
    printf '\[\033[01;'${prefix_color}'m\]%s %s\[\033[00m\]' '\u@\h' '\w'
  )"
  local branch_format=' :\[\033[01;'${branch_color}'m\]%s\[\033[00m\]'
  local branch; branch="\$( \
    typeset -F __git_ps1 &>/dev/null && __git_ps1 \"${branch_format}\" \
  )"

  PS1_ORIGIN="${PS1_ORIGIN:-${PS1}}"
  PS1_GIT="${PS1_GIT:-$(printf '[%s%s] ' "${prefix}" "${branch}")}"
  PS1="${PS1_GIT}"
}; _iife_ps1_git
