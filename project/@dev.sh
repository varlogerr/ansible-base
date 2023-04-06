# SPECIFICS:
# * internally environment file is loaded inside an immediately
#   invoked function with all possible side effects, like:
#   * you can use `local` keyword to create variables only
#     visible in the current environment file
#   * variables created with `declare` are only visible inside
#     the current file
# * You can source another environment (sub-environment), but:
#   * sub-environment is not registered in envar stack and files
#   * sub-environment is forced to deskless mode
#   * `-n` option is not applicable for sub-environment


declare CURDIR; CURDIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
envar_source -- "${CURDIR}/.envar"

# Configure env name
ENVAR_NAME="${ENVAR_NAME:+${ENVAR_NAME}:}$(basename -- "${CURDIR}")"

# # Playbook configuration variables:
# export ANSIBLE_PLAYBOOK_ASK_VAULT_PASS=true
# export ANSIBLE_PLAYBOOK_DEPS_FILE=requirements.yml
# export ANSIBLE_PLAYBOOK_INVENTORY_FILE=hosts.yml
# export ANSIBLE_PLAYBOOK_PLAYBOOK_FILE=playbook.yml
# export ANSIBLE_PLAYBOOK_VAULT_PASS_FILE=vault.pass
