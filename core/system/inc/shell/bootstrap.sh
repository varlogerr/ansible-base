_iife_bootstrap() {
  PROJ_DIR="$(realpath -- "${PROJ_BINDIR}/..")"
  SHELL_INCDIR="${CORE_DIR}/system/inc/shell"

  ANSIBLE_ROLES_PATH+="${ANSIBLE_ROLES_PATH:+:}${PROJ_DIR}/roles"
  ANSIBLE_ROLES_PATH+=":${CORE_DIR}/roles:${CORE_DIR}/system/roles"

  ANSIBLE_PLAYBOOK_ASK_VAULT_PASS=${ANSIBLE_PLAYBOOK_ASK_VAULT_PASS-true}
  ANSIBLE_PLAYBOOK_DEPS_FILE="${ANSIBLE_PLAYBOOK_DEPS_FILE:-requirements.yml}"
  ANSIBLE_PLAYBOOK_INVENTORY_FILE="${ANSIBLE_PLAYBOOK_INVENTORY_FILE:-hosts.yml}"
  ANSIBLE_PLAYBOOK_PLAYBOOK_FILE="${ANSIBLE_PLAYBOOK_PLAYBOOK_FILE:-playbook.yml}"
  ANSIBLE_PLAYBOOK_STRATEGY="${ANSIBLE_PLAYBOOK_STRATEGY:-}"
  ANSIBLE_PLAYBOOK_VAULT_PASS_FILE="${ANSIBLE_PLAYBOOK_VAULT_PASS_FILE:-vault.pass}"
}; _iife_bootstrap; unset _iife_bootstrap

. "${SHELL_INCDIR}/lib/shlib.sh"