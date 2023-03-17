#!/usr/bin/env bash

CORE_BINDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"
CORE_DIR="$(realpath -- "${CORE_BINDIR}/..")"
PROJ_BINDIR="${PROJ_BINDIR-$(realpath -- "$(dirname -- "${0}")")}"

declare -r CORE_BINDIR CORE_DIR PROJ_BINDIR

. "${CORE_DIR}/system/inc/shell/bootstrap.sh"

cd "${PROJ_DIR}" 2>/dev/null || trap_fatal --decore $? "
  Can't cd to the project dir:
 .  ${PROJ_DIR}
"

VAULT_PASS_FILE_STATE=unreadable
VAULT_PASS_SET_STATE=unset
VAULT_PASS_FILE_CONTENT="$(cat "${ANSIBLE_PLAYBOOK_VAULT_PASS_FILE}" 2>/dev/null)" \
&& VAULT_PASS_FILE_STATE=readable \
&& grep -v '^\s*$' <<< "${VAULT_PASS_FILE_CONTENT}" \
  | grep -v '^\s*#' | head -n 1 | wc -L | grep -qv '^0$' \
&& VAULT_PASS_SET_STATE=set

text_decore "
  VARS:
 .  CORE_DIR  : ${CORE_DIR}
 .  PROJ_DIR  : ${PROJ_DIR}
 .
  CONFIGURATION VARS:
 .  ANSIBLE_PLAYBOOK_ASK_VAULT_PASS   : ${ANSIBLE_PLAYBOOK_ASK_VAULT_PASS}
 .  ANSIBLE_PLAYBOOK_DEPS_FILE        : ${ANSIBLE_PLAYBOOK_DEPS_FILE}
 .  ANSIBLE_PLAYBOOK_INVENTORY_FILE   : ${ANSIBLE_PLAYBOOK_INVENTORY_FILE}
 .  ANSIBLE_PLAYBOOK_PLAYBOOK_FILE    : ${ANSIBLE_PLAYBOOK_PLAYBOOK_FILE}
 .  ANSIBLE_PLAYBOOK_STRATEGY         : ${ANSIBLE_PLAYBOOK_STRATEGY}
 .  ANSIBLE_PLAYBOOK_VAULT_PASS_FILE  : ${ANSIBLE_PLAYBOOK_VAULT_PASS_FILE} (${VAULT_PASS_FILE_STATE}, password is ${VAULT_PASS_SET_STATE})
 .
" | log_info

cat "${ANSIBLE_PLAYBOOK_DEPS_FILE}" &>/dev/null && {
  (
    set -x

    ansible-galaxy collection install -r requirements.yml \
    || ansible-galaxy collection install --force -r requirements.yml
  ) || trap_fatal --decore $? "
    Can't install ansible requirements
  "
}

declare -a PLAYBOOK_OPTS=(
  -i "${ANSIBLE_PLAYBOOK_INVENTORY_FILE}"
  "${ANSIBLE_PLAYBOOK_PLAYBOOK_FILE}"
)
if [[ "${VAULT_PASS_SET_STATE}" == set ]]; then
  PLAYBOOK_OPTS+=(--vault-password-file "${ANSIBLE_PLAYBOOK_VAULT_PASS_FILE}")
elif ${ANSIBLE_PLAYBOOK_ASK_VAULT_PASS-true}; then
  PLAYBOOK_OPTS+=(--ask-vault-pass)
fi

PLAYBOOK_START=$(date +%s)
declare -r PLAYBOOK_START

(
  export ANSIBLE_ROLES_PATH
  set -x
  ansible-playbook "${PLAYBOOK_OPTS[@]}" "${@}"
)

seconds=$(($(date +%s) - ${PLAYBOOK_START}))
printf '.\nTime taken: %02d:%02d:%02d\n.\n' \
  "$(( seconds / 60 / 60 ))" \
  "$(( seconds / 60 ))" \
  "$(( seconds % 60 ))" | text_decore | log_info


exit

UB_BINDIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
UB_COREDIR="$(realpath "${UB_BINDIR}/..")"

declare -a UB_OPTIONS
"${UB_ASK_PASS-true}" && UB_OPTIONS+=(--ask-vault-pass)

log_info \
  "CORE DIR:      ${UB_COREDIR}" \
  "PLAYBOOK FILE: ${UB_PLAYBOOK_FILE}" \
  "PLAYBOOK DIR:  ${UB_PLAYBOOK_DIR}" \
  "PLAYBOOK:      ${UB_PLAYBOOK}" \
  "INVENTORY:     ${UB_INVENTORY}" \
  "ROLES PATH:    ${ANSIBLE_ROLES_PATH}"

cd "${UB_PLAYBOOK_DIR}" 2>/dev/null \
  || trap_fatal $? "Can't cd to playbook dir: ${UB_PLAYBOOK_DIR}"

[[ -f requirements.yml ]] && (
  set -x
  ansible-galaxy collection install -r requirements.yml || {
    ansible-galaxy collection install --force -r requirements.yml \
      || exit 1
  }
)

start=$(date +%s)

(
  export ANSIBLE_ROLES_PATH
  set -x
  ansible-playbook "${UB_OPTIONS[@]}" -i "${UB_INVENTORY}" "${UB_PLAYBOOK}" "${@}"
)

seconds=$(($(date +%s) - ${start}))
printf 'Time taken: %02d:%02d:%02d\n' "$(( seconds / 60 / 60 ))" \
                      "$(( seconds / 60 ))" "$(( seconds % 60 ))" \
| log_info
