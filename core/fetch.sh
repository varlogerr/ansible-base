#!/usr/bin/env bash

declare -A OPTS
declare -Ar DEFAULTS=(
  [branch]=master
  [dest]=.
)

print_help() {
  local script_path="${0}"
  local script_name=fetch.sh
  [[ -f "$(realpath -m -- "${script_path}" 2>/dev/null)" ]] && {
    script_name="$(basename -- "${script_path}")"
  }

  echo "
    Fetch ansible project core
   .
    USAGE:
   .  ${script_name} [-b|--branch BRANCH] [--] [DEST]
   .
    DEFAULTS:
   .  BRANCH  - ${DEFAULTS[branch]}
   .  DEST    - ${DEFAULTS[dest]}
  " | grep -v '^\s*$' | sed -e 's/^\s*//' -e 's/^$//' -e 's/^\.//'
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
      *             ) OPTS[dest]="${1}" ;;
    esac

    shift
  done

  local k d; for k in "${!DEFAULTS[@]}"; do
    [[ -n "${OPTS[${k}]+x}" ]] && continue

    d="${DEFAULTS[${k}]}"
    OPTS[${k}]="${d}"
  done
}; _iife_parse_opts "${@}"

trap_fatal() {
  echo "[fatal] ${2}" >&2
  exit ${1}
}

declare -r PKGNAME=ansible-base
declare -r DL_URL="https://github.com/varlogerr/${PKGNAME}/archive/refs/heads/${OPTS[branch]}.tar.gz"
declare -a DL_CMD

if curl --version &>/dev/null; then
  DL_CMD+=(curl -fsL -o -)
elif wget --version &>/dev/null; then
  DL_CMD+=(wget -qO-)
else
  trap_fatal 1 'curl or wget is required'
fi
DL_CMD+=("${DL_URL}")

TMPDIR="$(set -x; mktemp -d --suffix ".${PKGNAME}" 2>/dev/null)" || {
  trap_fatal $? "Can't create temp directory"
}
declare -r TMPDIR

(
  set -o pipefail
  set -x
  "${DL_CMD[@]}" 2>/dev/null | tar -xzf - -C "${TMPDIR}" 2>/dev/null
) || { trap_fatal $? 'Downloaded package is corrupted'; }

declare -r PKG_TMPDIR="${TMPDIR}/${PKGNAME}-${OPTS[branch]}"
declare -r SHLIB_TMP_PATH="${PKG_TMPDIR}/core/system/inc/shell/lib/shlib.sh"

. "${SHLIB_TMP_PATH}" &>/dev/null || {
  trap_fatal $? "Can't source ${SHLIB_TMP_PATH}"
}

(set -x; cp -rf "${PKG_TMPDIR}"/.editorconfig "${PKG_TMPDIR}/core" &>/dev/null) || {
  trap_fatal $? "Can't copy assets to core"
}

(set -x; mv "${PKG_TMPDIR}"/core/fetch.sh "${PKG_TMPDIR}/core/system/bin/fetch-core.sh" &>/dev/null) || {
  trap_fatal $? "Can't move core fetch to system/bin"
}
(
  set -x
  find "${PKG_TMPDIR}/core/system/bin" "${PKG_TMPDIR}/core/bin" \
    -mindepth 1 -maxdepth 1 -type f -name '*.sh' \
    -exec chmod 0755 {} \; &>/dev/null
) || {
  trap_fatal $? "Can't chmod binaries"
}

(set -x; mkdir -p "${OPTS[dest]}" &>/dev/null) || {
  trap_fatal $? "Can't create DEST directory ${OPTS[dest]}"
}
(set -x; cp -rf "${PKG_TMPDIR}/core"/. "${OPTS[dest]}" &>/dev/null) || {
  trap_fatal $? "Can't move core to ${OPTS[dest]}"
}

(
  set -x
  find "${TMPDIR}" \
    -mindepth 1 -maxdepth 1 \
    -exec rm -rf {} \; &>/dev/null \
  && rmdir "${TMPDIR}" &>/dev/null
) || { trap_fatal $? "Can't remove ${TMPDIR}"; }
