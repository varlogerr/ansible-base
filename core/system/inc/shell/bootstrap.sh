#
# Requirements:
# * PROJ_HOME directory path
# * CORE_HOME directory path
#
_iife_bootstrap() {
  [[ -n "${CORE_HOME}" ]] || {
    echo "[fatal] CORE_HOME is required in bootstrap.sh" >&2
    exit
  }
  [[ -n "${PROJ_HOME}" ]] || {
    echo "[fatal] PROJ_HOME is required in bootstrap.sh" >&2
    exit
  }

  CORE_BINDIR="${CORE_HOME}/bin"
  PROJ_BINDIR="${PROJ_HOME}/bin"

  { # Detect ANSIBLE_ROLES_PATH
    local path
    local -a tmp_path_arr
    local -a path_arr
    local dir; for dir in \
      "${PROJ_HOME}" \
      "${CORE_HOME}" \
    ; do
      path="$(
        grep '^\s*roles_path\s*=' "${dir}/ansible.cfg" 2>/dev/null \
        | cut -d= -f2 | sed -e 's/^\s*//' -e 's/\s*$//'
      )"
      [[ -n "${path}" ]] || continue

      mapfile -t tmp_path_arr <<< "$(tr ':' '\n' <<< "${path}")"
      local i; for i in "${tmp_path_arr[@]}"; do
        path_arr+=("$(cd "${dir}"; realpath -m -- "${i}")")
      done
    done

    path="$(printf -- '%s\n' "${path_arr[@]}" | uniq_ordered)"

    ANSIBLE_ROLES_PATH+="${ANSIBLE_ROLES_PATH:+:}"
    ANSIBLE_ROLES_PATH+="$(tr '\n' ':' <<< "${path}" | sed 's/:\+$//')"
  } # Detect ANSIBLE_ROLES_PATH

  ANSIBLE_PLAYBOOK_ASK_VAULT_PASS=${ANSIBLE_PLAYBOOK_ASK_VAULT_PASS-true}
  ANSIBLE_PLAYBOOK_DEPS_FILE="${ANSIBLE_PLAYBOOK_DEPS_FILE:-requirements.yml}"
  ANSIBLE_PLAYBOOK_INVENTORY_FILE="${ANSIBLE_PLAYBOOK_INVENTORY_FILE:-hosts.yml}"
  ANSIBLE_PLAYBOOK_PLAYBOOK_FILE="${ANSIBLE_PLAYBOOK_PLAYBOOK_FILE:-playbook.yml}"
  ANSIBLE_PLAYBOOK_STRATEGY="${ANSIBLE_PLAYBOOK_STRATEGY:-}"
  ANSIBLE_PLAYBOOK_VAULT_PASS_FILE="${ANSIBLE_PLAYBOOK_VAULT_PASS_FILE:-vault.pass}"
}; _iife_bootstrap; unset _iife_bootstrap
