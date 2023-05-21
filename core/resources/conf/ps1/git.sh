# To skip changing PS1 to PS1_GIT, paste
#   PS1_GIT="${PS1}"
# before the current script is sourced, or
#   PS1="${PS1_ORIGIN}"
# after the current script is sourced
_iife_ps1_git() {
  unset _iife_ps1_git

  declare -A color
  [ $(id -u) -eq 0 ] && color=(
    # root colors
    [prefix]=36
    [branch]=33
  ) || color=(
    # non-root colors
    [prefix]=32
    [branch]=33
  )

  # define formats
  local branch_format=' :\[\033[01;'${color[branch]}'m\]%s\[\033[00m\]'
  declare -A format; format=(
    [prefix]="$(printf '\[\033[01;'${color[prefix]}'m\]%s %s\[\033[00m\]' '\u@\h' '\w')"
    [branch]='$(__git_ps1 '"'${branch_format}'"' 2>/dev/null)'
  )

  # format PS1
  PS1_ORIGIN="${PS1_ORIGIN:-${PS1}}"
  PS1_GIT="${PS1_GIT:-$(printf -- '[%s%s] ' "${format[prefix]}" "${format[branch]}")}"
  PS1="${PS1_GIT}"
}; _iife_ps1_git
