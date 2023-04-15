#!/usr/bin/env bash

declare -A OPTS
declare -Ar DEFAULTS=(
  [branch]=master
  [spaced]=false
  [dest]=
)

CORE_SYS_BINDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
CORE_HOME="$(realpath -- "${CORE_SYS_BINDIR}/../..")"
CORE_SHELL_INCDIR="${CORE_HOME}/system/inc/shell"

# source shlib
declare -r SHLIB_PATH="${CORE_SHELL_INCDIR}/lib/shlib.sh"
. "${SHLIB_PATH}" &>/dev/null || {
  trap_fatal $? "Can't source ${SHLIB_PATH}"
}

print_help() {
  local script_name="$(basename -- "${0}")"
  local spacing='                '

  text_decore "
    Generate vars from all available roles for the DEST project to stdout
   .
    USAGE:
   .  ${script_name} [-b|--branch BRANCH] [--spaced] [--] DEST
   .
    OPTIONS:
    -b, --branch  Branch to pull from, defaults to ${DEFAULTS[branch]}
    --spaced      Prefix default vars content with 2 spaces
  "
}

_iife_parse_opts() {
  unset _iife_parse_opts

  local endopts=false

  local arg; while :; do
    [[ -n "${1+x}" ]] || break
    ${endopts} && arg='*' || arg="${1}"

    case "${arg}" in
      --            ) endopts=true ;;
      -\?|-h|--help ) print_help; exit ;;
      -b|--branch   ) shift; OPTS[branch]="${1}" ;;
      --spaced      ) OPTS[spaced]=true ;;
      *             ) OPTS[dest]="${1}" ;;
    esac

    shift
  done

  local k d; for k in "${!DEFAULTS[@]}"; do
    [[ -n "${OPTS[${k}]+x}" ]] && continue

    d="${DEFAULTS[${k}]}"
    OPTS[${k}]="${d}"
  done

  [[ -n "${OPTS[dest]}" ]] || trap_fatal $? "DEST is required"
}; _iife_parse_opts "${@}"

PROJ_HOME="$(realpath -m -- "${OPTS[dest]}" 2>/dev/null)"
# source bootstrap
declare -r BOOTSTRAP_PATH="${CORE_SHELL_INCDIR}/bootstrap.sh"
. "${BOOTSTRAP_PATH}" &>/dev/null || {
  trap_fatal $? "Can't source ${BOOTSTRAP_PATH}"
}

declare -A SNIPPET_TO_TPL
_iife_get_snippets() {
  unset _iife_get_snippets

  local content
  local snippet_name
  while read -r f; do
    content="$(cat "${f}")"
    snippet_name="$(basename -s '.yml' -- "${f}")"
    SNIPPET_TO_TPL[${snippet_name}]="${content}"
  done < <(
    find "${CORE_HOME}/system/snippets/vars" \
      -mindepth 1 -maxdepth 1 -type f -name '*.yml'
  )
}; _iife_get_snippets
declare -r SNIPPET_TO_TPL

parse_snippet() {
  local comment="${1}"
  local match
  local match_line_no
  local args_nl
  local -a args
  local arg_no
  local arg
  local snippet
  local name; for name in "${!SNIPPET_TO_TPL[@]}"; do
    match="$(
      set -o pipefail
      grep -n '^\s*#\s*!snippet\.'"${name} " <<< "${content}"
    )" || continue

    match_line_no="${match%%:*}"
    args_nl="$(cut -d':' -f2- <<< "${match} " | text_decore \
      | sed -e 's/\s\+/ /g' | sed -e 's/#\s*//' | sed 's/$/ /' | cut -d' ' -f2- | tr ' ' '\n')"

    args=()
    [[ -n "${args_nl}" ]] && mapfile -t args <<< "${args_nl}"

    snippet="${SNIPPET_TO_TPL[${name}]}"
    for arg_no in "${!args[@]}"; do
      arg="$(sed_quote_replace "${args[${arg_no}]}")"
      snippet="$(sed -e 's/{{\s*'${arg_no}'\s*}}/'"${arg}"'/g' <<< "${snippet}")"
    done

    comment="$(
      head -n $((match_line_no - 1)) <<< "${comment}"
      echo "${snippet}"
      tail -n +$((match_line_no + 1)) <<< "${comment}"
    )"
  done

  echo "${comment}"
}

declare VARS_CONTENT
_iife_roles_vars() {
  unset _iife_roles_vars

  local etc_dir=etc/playbook

  local exclude_dirs; exclude_dirs="$(
    path="${etc_dir}/exclude-role-dirs.conf"
    (cat "${PROJ_HOME}/${path}" 2>/dev/null || cat "${PKG_TMPDIR}/project/${path}" 2>/dev/null) \
    | grep -v -e '^\s*$' -e '^\s*#' | text_clean
  )"
  [[ -n "${exclude_dirs}" ]] || exclude_dirs='^$'

  local roles_dirs; roles_dirs="$(
    tr ':' '\n' <<< "${ANSIBLE_ROLES_PATH}" | grep -vf <(echo "${exclude_dirs}")
  )"

  local -a roles_dirs_arr; mapfile -t roles_dirs_arr <<< "${roles_dirs}"
  local exclude_roles; exclude_roles="$(
    path="${etc_dir}/exclude-roles.conf"
    (cat "${PROJ_HOME}/${path}" 2>/dev/null || cat "${PKG_TMPDIR}/project/${path}" 2>/dev/null) \
    | grep -v -e '^\s*$' -e '^\s*#' | text_clean
  )"

  local roles_tmp; roles_tmp="$(
    set -o pipefail

    find "${roles_dirs_arr[@]}" \
      -type f -path '*/tasks/main.yml' 2>/dev/null \
    | rev | cut -d'/' -f3- | rev | sort -u -t '/' -k2 \
    | LC_ALL=C sort -u -t '/' -k1
  )" || trap_fatal $? "Can't find roles"

  local -A vars_by_roles_dir
  local roles_dir
  local roles_name
  local defaults_file
  local content
  local d; for d in ${roles_tmp}; do
    defaults_file="${d}/defaults/main.yml"

    content="$(
      set -o pipefail
      cat "${defaults_file}" 2>/dev/null \
      | text_rmblank | sed '1{/^---$/d}' \
      | sed 's/^\s*#/#/'
    )" || continue
    [[ -n "${content}" ]] || continue

    content="$(parse_snippet "${content}")"
    ${OPTS[spaced]} && content="$(
      sed 's/^/  /' <<< "${content}"
    )"

    roles_dir="$(rev <<< "${d}" | cut -d'/' -f2 | rev)"
    role_name="${d##*/}"
    content="##### ${role_name^^}"$'\n'"${content}"

    vars_by_roles_dir["${roles_dir}"]+="${vars_by_roles_dir[${roles_dir}]:+$'\n\n'}${content}"
  done

  local -a keys; mapfile -t keys <<< "$(
    printf -- '%s\n' "${!vars_by_roles_dir[@]}" | sort -n
  )"

  local roles_dir_len
  local roles_dir_underline
  local k; for k in "${keys[@]}"; do
    roles_dir_len="${#k}"
    roles_dir_underline="$(seq 1 $((roles_dir_len + 20)) | xargs printf -- '#%.0s')"

    VARS_CONTENT+="${VARS_CONTENT:+$'\n\n\n'}"
    VARS_CONTENT+="$(text_decore "
      ${roles_dir_underline}
      #         ${k^^}         #
      ${roles_dir_underline}
    ")"
    VARS_CONTENT+=$'\n\n'"${vars_by_roles_dir["${k}"]}"
  done
}; _iife_roles_vars

[[ -n "${VARS_CONTENT}" ]] && echo "---"$'\n'"${VARS_CONTENT}"
