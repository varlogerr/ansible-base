_iife_desk_bootstrap() {
  DESK_INIT_PS1="${DESK_INIT_PS1-${PS1}}"
  [[ -n ${DESK_NAME:+x} ]] && _DESK_STACK="${DESK_NAME}${_DESK_STACK:+$'\n'}${_DESK_STACK}"

  export DESK_INIT_PS1
  export _DESK_STACK
}; _iife_desk_bootstrap; unset _iife_desk_bootstrap

desk_gen() {
  local -r func="${FUNCNAME[0]}"

  _desk_trap_help_opt "${@}" && echo "
    Generate a basic desk.
   .
    USAGE
    =====
   .  # Generate a desk
   .  ${func} DESK_NAME
   .  # Edit it
   .  desk edit DESK_NAME
   .  # Use it
   .  desk . DESK_NAME
   .  # Generate to stdout, that can be redirected
   .  # to a Deskfile
   .  ${func}
  " | grep -v '^\s*$' | sed -e 's/^\s*//' -e 's/\.//' && return

  local -r prifix="${DESK_DIR:-${HOME}/.desk}"
  local -r desks="${DESK_DESKS_DIR:-${prifix}/desks}"
  local -r name="${1}"
  local dest_file; dest_file="$(realpath -m -- "${desks}/${name}.sh")"
  local template='
    # Description: TBD
   .
    { # Base configuration
   .  #
   .  # ==========
   .  # Alter `PS1` to see what desk you are using.
   .  # `DESK_INIT_PS1` keeps initial PS1.
   .  # `DESK_NAME` contains current desk name.
   .  # ==========
   .  PS1="${DESK_INIT_PS1}desk@${DESK_NAME} > "
   .  #
    } # Base configuration
  '; template="$(
    grep -v '^\s*$' <<< "${template}" \
    | sed -e 's/^\s*//' -e 's/\.//'
  )"

  [[ -n "${name}" ]] || { cat <<< "${template}"; return; }

  [[ -e "${dest_file}" ]] && { _desk_fail "Desk ${name} already exists"; return; }

  (set -x; mkdir -p "${desks}" &>/dev/null) || {
    _desk_fail "Can't create desks directory ${desks}"
    return
  }

  (set -x; tee "${dest_file}" <<< "${template}" &>/dev/null) || {
    _desk_fail "Can't create desk ${name}"
    return
  }
}

desk_stack() {
  local -r func="${FUNCNAME[0]}"

  _desk_trap_help_opt "${@}" && echo "
    View desks stack.
   .
    USAGE
    =====
   .  # View stack
   .  # -r, --reverse   Reverse the order (i.e. queue instead of stack)
   .  # -u, --uniq      Unique entries. In conjunction with \`-r\` unique
   .  #                 filter is applied after reverse
   .  ${func} [-r|--reverse] [-u|--uniq]
  " | grep -v '^\s*$' | sed -e 's/^\s*//' -e 's/\.//' && return

  local -a filter1=cat
  local -a filter2=cat

  while :; do
    [[ -n "${1+x}" ]] || break
    case "${1}" in
      -r|--reverse  ) filter1=tac ;;
      -u|--uniq     ) filter2=_desk_filter_uniq ;;
    esac
    shift
  done

  [[ -n ${_DESK_STACK:+x} ]] && {
    echo "${_DESK_STACK}" | "${filter1}" | "${filter2}"
  }
}

desk_ps1_reset() {
  local -r func="${FUNCNAME[0]}"

  _desk_trap_help_opt "${@}" && echo "
    Reset PS1 to its before-desk value.
   .
    USAGE
    =====
   .  ${func}
  " | grep -v '^\s*$' | sed -e 's/^\s*//' -e 's/\.//' && return

  [[ (
    -n "${DESK_NAME:+x}" \
    && "${DESK_INIT_PS1}" != "${PS1}"
  ) ]] && PS1="${DESK_INIT_PS1}"
}

#
# PRIVATE
#

_desk_fail() {
  local msg="${1}"
  echo "[fatal] ${msg}" >&2
  return 1
}

_desk_trap_help_opt() {
  local endopts=false
  local arg; while :; do
    [[ -n "${1+x}" ]] || break
    ${endopts} && arg='*' || arg="${1}"

    case "${arg}" in
      --            ) endopts=true ;;
      -\?|-h|--help ) return 0 ;;
    esac

    shift
  done

  return 1
}

_desk_filter_uniq() {
  cat -n | sort -k2 -k1n | uniq -f1 | sort -nk1,1 | cut -f2-
}

[ -n "${DESK_ENV}" ] && source "${DESK_ENV}" || true
