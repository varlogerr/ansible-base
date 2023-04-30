#!/usr/bin/env bash

CORE_HOME="${CORE_HOME-$(realpath -- "$(dirname -- "$(realpath -- "${0}")")/..")}"
PROJ_HOME="${PROJ_HOME-$(realpath -- "$(dirname -- "${0}")/..")}"
declare -r CORE_HOME PROJ_HOME

. "${CORE_HOME}/system/inc/shell/lib/shlib.sh"
. "${CORE_HOME}/system/inc/shell/bootstrap.sh"

cd "${PROJ_HOME}" 2>/dev/null || trap_fatal --decore $? "
  Can't cd to the project dir:
 .  ${PROJ_HOME}
"

print_help() {
  local script_name="$(basename -- "${0}")"

  text_decore "
    Wrapper for ansible-playbook.
   .
    USAGE:
   .  ${script_name}
   .
  ansible-playbook help follows
 .
  =========================
 .
  "
}

trap_help_opt "${@}" && {
  print_help
  ansible-playbook "${@}"
  exit $?
}

VAULT_PASS_FILE_STATE=unreadable
VAULT_PASS_SET_STATE=unset
VAULT_PASS_FILE_CONTENT="$(cat "${ANSIBLE_PLAYBOOK_VAULT_PASS_FILE}" 2>/dev/null)" \
&& VAULT_PASS_FILE_STATE=readable \
&& grep -v '^\s*$' <<< "${VAULT_PASS_FILE_CONTENT}" \
  | grep -v '^\s*#' | head -n 1 | wc -L | grep -qv '^0$' \
&& VAULT_PASS_SET_STATE=set

text_decore "
  VARS:
 .  CORE_HOME : ${CORE_HOME}
 .  PROJ_HOME : ${PROJ_HOME}
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
  set -x
  ansible-playbook "${PLAYBOOK_OPTS[@]}" "${@}"
)

seconds=$(($(date +%s) - ${PLAYBOOK_START}))
printf '.\nTime taken: %02d:%02d:%02d\n.\n' \
  "$(( seconds / 60 / 60 ))" \
  "$(( seconds / 60 ))" \
  "$(( seconds % 60 ))" | text_decore | log_info
