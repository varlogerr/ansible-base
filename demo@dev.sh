#
# For development copy configuration block to @dev.sh and
# and change variables values
#

{ # Configuration block
  # Configure env name
  ENVAR_NAME="${ENVAR_NAME:-playbook.dev}"

  # Configure hosts addresses
  HOST_ALMALINUX="${HOST_ALMALINUX:-almalinux.home}"
  HOST_DEBIAN="${HOST_DEBIAN:-debian.home}"
  HOST_MINT="${HOST_MINT:-mint.home}"
  HOST_UBUNTU="${HOST_UBUNTU:-ubuntu.home}"

  # Configure hosts credentials
  HOSTS_USER="${HOSTS_USER:-ansible-user}"
  HOSTS_USER_PASS="${HOSTS_USER_PASS:-secret-password}"

  # Configure playbook ask vault param
  ANSIBLE_PLAYBOOK_ASK_VAULT_PASS="${ANSIBLE_PLAYBOOK_ASK_VAULT_PASS:-false}"

  # # Uncomment and leave as is
  # CURDIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
  # envar_source -- "${CURDIR}/demo@dev.sh"
} # Configuration block

export HOST_ALMALINUX \
  HOST_DEBIAN \
  HOST_MINT \
  HOST_UBUNTU \
  HOSTS_USER \
  HOSTS_USER_PASS \
  ANSIBLE_PLAYBOOK_ASK_VAULT_PASS

alias ssh.almalinux="sshpass -p "${HOSTS_USER_PASS}" ssh ${HOSTS_USER}@${HOST_ALMALINUX}"
alias ssh.debian="sshpass -p "${HOSTS_USER_PASS}" ssh ${HOSTS_USER}@${HOST_DEBIAN}"
alias ssh.mint="sshpass -p "${HOSTS_USER_PASS}" ssh ${HOSTS_USER}@${HOST_MINT}"
alias ssh.ubuntu="sshpass -p "${HOSTS_USER_PASS}" ssh ${HOSTS_USER}@${HOST_UBUNTU}"
