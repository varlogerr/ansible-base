#!/usr/bin/env bash

declare -A OPTS
declare -Ar DEFAULTS=(
  [branch]=master
  [dest]=
  # [refetch]=
)

CORE_SYS_BINDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
CORE_HOME="$(realpath -- "${CORE_SYS_BINDIR}/../..")"
CORE_SHELL_INCDIR="${CORE_HOME}/system/inc/shell"

declare -A REFETCH_OPTIONS_MAP=(
  [bins]=bin/demo.sh
  [book]=playbook.yml
  [conf]=project.conf
  [req]=requirements.yml
)
REFETCH_OPTIONS="$(
  printf -- '%s\n' "${!REFETCH_OPTIONS_MAP[@]}"| sort -n | uniq
)"; declare -r REFETCH_OPTIONS

# source shlib
declare -r SHLIB_PATH="${CORE_SHELL_INCDIR}/lib/shlib.sh"
. "${SHLIB_PATH}" &>/dev/null || {
  trap_fatal $? "Can't source ${SHLIB_PATH}"
}

print_help() {
  local spacing='                '

  text_decore "
    Fetch ansible project
   .
    USAGE:
   .  fetch-project.sh [-b|--branch BRANCH] [-f|--refetch REFETCH]... [--] DEST
   .
    OPTIONS:
    -b, --branch    Branch to pull from, defaults to ${DEFAULTS[branch]}
    -f, --refetch   Refetch some important files. Available options:
  " "
    $(text_clean 'all' "${REFETCH_OPTIONS}" | sed "s/^/.${spacing}* /")
  " "
   .
    $(print_after_fetch)
  "
}

print_after_fetch() {
  echo "
    AFTER FETCH:
    * symlink desired core binaries to project \`{PROJ_DIR}/bin\` directory:
   .  ln -sf '{CORE_DIR}/bin/{SRC_BIN}.sh' '{PROJ_DIR}/bin/{DEST_BIN}.sh'
    * (optional, nice for development) symlink fetch-core.sh script to project
   .  \`{PROJ_DIR}/system/bin\` directory:
   .  ln -sf '{CORE_DIR}/system/bin/fetch-core.sh' '{PROJ_DIR}/system/bin/fetch-core.sh'
    * review and edit configurations:
   .  * \`{PROJ_DIR}/@dev.sh\`
   .  * \`{PROJ_DIR}/etc\`
   .  * \`{PROJ_DIR}/ansible.cfg\`
   .  * \`{PROJ_DIR}/hosts.yml\`
   .  * \`{PROJ_DIR}/playbook.yml\`
   .  * \`{PROJ_DIR}/project.conf\`
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
      -f|--refetch  ) shift; OPTS[refetch]+="${OPTS[refetch]:+$'\n'}${1}" ;;
      *             ) OPTS[dest]="${1}" ;;
    esac

    shift
  done

  [[ -n "${OPTS[refetch]+x}" ]] && {
    if [[ -n "${OPTS[refetch]}" ]]; then
      OPTS[refetch]="$(sort -n <<< "${OPTS[refetch]}" | uniq)"

      local inval; inval="$(
        grep -vFxf <(
          text_clean 'all' "${REFETCH_OPTIONS}"
        ) <<< "${OPTS[refetch]}"
      )" && trap_fatal --decore 1 -- "
        Invalid refetch values:
        $(sed 's/^/* /' <<< "${inval}")
       .
        Available values:
        $(text_clean 'all' "${REFETCH_OPTIONS}" | sed 's/^/* /')
      "

      grep -qFx 'all' <<< "${OPTS[refetch]}" \
      && OPTS[refetch]="${REFETCH_OPTIONS}"
    else
      trap_fatal $? "REFETCH is required"
    fi
  }

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

declare -r PKGNAME=ansible-base
declare -r DL_URL="https://github.com/varlogerr/${PKGNAME}/archive/refs/heads/${OPTS[branch]}.tar.gz"
declare -a DL_CMD

CORE_HOME_REL="$(
  realpath -m --relative-to "${PROJ_HOME}" -- "${CORE_HOME}"
)" || trap_fatal $? "Can't detect core bins"
declare -r CORE_HOME_REL

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

_iife_roles_to_playbook() {
  unset _iife_roles_to_playbook

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
    | rev | cut -d'/' -f3,4 | rev | sort -u -t '/' -k2 \
    | LC_ALL=C sort -u -t '/' -k1
  )" || trap_fatal $? "Can't find roles"

  local -A dir_to_roles_map
  local k
  local r; for r in ${roles_tmp}; do
    k="${r%/*}"
    dir_to_roles_map["${k}"]+="${dir_to_roles_map["${k}"]:+$'\n'}${r##*/}"
  done

  local roles; roles="$(
    printf -- '%s\n' "${!dir_to_roles_map[@]}" \
    | sort -n | while read -r k; do
      echo "### { ${k}"
      echo "${dir_to_roles_map["${k}"]}" | grep -vFxf <(echo "${exclude_roles}")
      echo "### } ${k}"
    done
  )"

  [[ -n "${roles}" ]] || return

  text_decore "
    .
    Exclude role:
    $(sed 's/^/* /' <<< ""${exclude_roles}"")
    .
  " | log_info

  sed -e 's/^\([^#]\)/    - \1/' -e 's/^\(#\)/  \1/' <<< "${roles}" | (
    set -x; tee -a "${PKG_TMPDIR}/project/playbook.yml" >/dev/null
  ) || trap_fatal $? "Can't add roles to the playbook"
}; _iife_roles_to_playbook

_iife_proj_conf() {
  unset _iife_proj_conf

  local conf_path="${PKG_TMPDIR}/project/project.conf"
  local -A repl_map; repl_map=(
    [core_home]="$(sed_quote_replace "${CORE_HOME_REL}")"
  )
  local -a cmd
  local k; for k in "${!repl_map[@]}"; do
    cmd+=(-e 's/^\s*\('"${k}"'\)\s*=\s*.*$/\1 = '"${repl_map[${k}]}"'/')
  done

  (set -x; sed -i "${cmd[@]}" "${conf_path}" 2>/dev/null) || {
    trap_fatal $? "Can't update project.conf"
  }
}; _iife_proj_conf

_iife_ansible_conf() {
  unset _iife_ansible_conf

  local conf_path="${PKG_TMPDIR}/project/ansible.cfg"
  local -a path_arr; mapfile -t path_arr <<< "$(
    tr ':' '\n' <<< "${ANSIBLE_ROLES_PATH}"
  )"
  local -a path_rel_arr
  local p; for p in "${path_arr[@]}"; do
    path_rel_arr+=("$(realpath -m --relative-to "${PROJ_HOME}" -- "${p}")")
  done
  local path_rel; path_rel="$(
    cat -- \
      <(echo roles) \
      <(tr ' ' '\n' <<< "${path_rel_arr[@]}") \
      2>/dev/null | uniq_ordered \
      | tr '\n' ':' | sed -e 's/:$//'
  )"

  local -A repl_map; repl_map=(
    [roles_path]="$(sed_quote_replace "${path_rel}")"
  )
  local -a cmd
  local k; for k in "${!repl_map[@]}"; do
    cmd+=(-e 's/^\s*\('"${k}"'\)\s*=\s*.*$/\1 = '"${repl_map[${k}]}"'/')
  done

  (set -x; sed -i "${cmd[@]}" "${conf_path}" 2>/dev/null) || {
    trap_fatal $? "Can't update ansible.cfg"
  }
}; _iife_ansible_conf

_iife_manage_bin_symlinks() {
  unset _iife_manage_bin_symlinks

  local core_bins; core_bins="$(
    find "${CORE_HOME}/bin" -mindepth 1 -maxdepth 1 -name '*.sh' \
    | rev | cut -d'/' -f1 | rev \
    | sed 's/^/'"$(sed_quote_replace "../${CORE_HOME_REL}/bin/")"'/'
  )"
  local core_bins_arr; mapfile -t core_bins_arr <<< "${core_bins}"

  (
    set -x
    cd "${PKG_TMPDIR}/project/bin" 2>/dev/null \
    && ln -sf "${core_bins_arr[@]}" ./ 2>/dev/null
  ) || trap_fatal $? "Can't manage bin symlinks"
}; _iife_manage_bin_symlinks

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

_iife_cp_to_dest() {
  unset _iife_cp_to_dest

  [[ -n "$(ls -A "${OPTS[dest]}")" ]] || {
    (set -x; cp -rf "${PKG_TMPDIR}/project"/. "${OPTS[dest]}" &>/dev/null) || {
      trap_fatal $? "Can't copy project to ${OPTS[dest]}"
    }

    return 0
  }

  [[ -n "${OPTS[refetch]}" ]] || trap_fatal --decore $? "
    Not empty directory ${OPTS[dest]}. See \`--refetch\` option:
  "

  declare -a refetches; mapfile -t refetches <<< "${OPTS[refetch]}"
  declare -a err
  local file
  local dest_file
  local dest_dir
  local o; for o in "${refetches[@]}"; do
    file="${REFETCH_OPTIONS_MAP[${o}]}"
    dest_file="${OPTS[dest]}/${file}"
    dest_dir="$(dirname -- "${dest_file}")"
    (
      set -x
      mkdir -p "${dest_dir}" &>/dev/null \
      && cp -f "${PKG_TMPDIR}/project/${file}" "${dest_file}" &>/dev/null
    ) || {
      log_warn "Can't copy to ${dest_file}"
    }
  done
}; _iife_cp_to_dest

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
