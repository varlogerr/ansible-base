#!/usr/bin/env bash

declare -A OPTS
declare -Ar DEFAULTS=(
  [branch]=master
  [dest]=.
)

print_help() {
  echo "
    Fetch ansible project
   .
    USAGE:
   .  fetch-project.sh [-b|--branch BRANCH] [--] [DEST]
   .
    DEFAULTS:
   .  BRANCH  - ${DEFAULTS[branch]}
   .  DEST    - ${DEFAULTS[dest]}
   .
    $(print_after_fetch)
  " | grep -v '^\s*$' | sed -e 's/^\s*//' -e 's/^$//' -e 's/^\.//'
}

print_after_fetch() {
  echo "
    AFTER FETCH:
    * symlink required core binaries to project \`{PROJ_DIR}/bin\` directory
   .  ln -sf '{CORE_DIR}/bin/{SRC_BIN}.sh' '{PROJ_DIR}/bin/{DEST_BIN}.sh'
    * review and edit configurations:
   .  * \`{PROJ_DIR}/@dev.sh\`
   .  * \`{PROJ_DIR}/hosts.yml\`
   .  * \`{PROJ_DIR}/playbook.yml\`
   .  * \`{PROJ_DIR}/resources/env-*.yml\`
   .  * \`{PROJ_DIR}/resources/secrets/becomer/demo1.pass\`
   .  * \`{PROJ_DIR}/vault.pass\`
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

_iife_roles_to_playbook() {
  unset _iife_roles_to_playbook

  local roles_dir="${PKG_TMPDIR}/core/roles"
  local playbook_path="${PKG_TMPDIR}/project/playbook.yml"

  local roles="$(
    set -o pipefail

    find "${roles_dir}" \
      -type f -path '*/tasks/main.yml' 2>/dev/null \
    | sort -n \
    | rev | cut -d'/' -f3 | rev
  )" || trap_fatal $? "Can't find roles"

  [[ -n "${roles}" ]] && {
    declare -a roles_arr
    mapfile -t roles_arr <<< "${roles}"

    printf -- '    # - %s\n' "${roles_arr[@]}" | (
      set -x; tee -a "${playbook_path}" >/dev/null
    ) || trap_fatal $? "Can't add roles to the playbook"
  }
}; _iife_roles_to_playbook

(set -x; cp -rf "${PKG_TMPDIR}"/.editorconfig "${PKG_TMPDIR}/project" &>/dev/null) || {
  trap_fatal $? "Can't copy assets to project"
}

_iife_vault_pass_file() {
  unset _iife_vault_pass_file

  local pass_file="${PKG_TMPDIR}/project/vault.pass"

  text_decore "
    # If you don't want to enter vault password
    # each time you run playbook, paste it here.
    # Empty lines and comments are ignored
  " | (set -x; tee "${pass_file}" &>/dev/null) || {
    trap_fatal -- $? "Can't create vault pass file"
  }

  (set -x; chmod 0600 "${pass_file}" &>/dev/null) || {
    trap_fatal -- $? "Can't chmod vault pass file"
  }
}; _iife_vault_pass_file

(set -x; mkdir -p "${OPTS[dest]}" &>/dev/null) || {
  trap_fatal $? "Can't create DEST directory ${OPTS[dest]}"
}

[[ -z "$(ls -A "${OPTS[dest]}")" ]] || {
  trap_fatal $? "Not empty directory ${OPTS[dest]}"
}

(set -x; cp -rf "${PKG_TMPDIR}/project"/. "${OPTS[dest]}" &>/dev/null) || {
  trap_fatal $? "Can't move core to ${OPTS[dest]}"
}

(
  set -x
  find "${TMPDIR}" \
    -mindepth 1 -maxdepth 1 \
    -exec rm -rf {} \; &>/dev/null \
  && rmdir "${TMPDIR}" &>/dev/null
) || { log_warn "Can't remove ${TMPDIR}"; }

_iife_final_info() {
  text_decore "
   .
    $(print_after_fetch)
   .
  " | log_info
}; _iife_final_info; unset _iife_final_info
