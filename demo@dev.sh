#
# For development copy it to @dev.sh and source
#

# Configure env name
ENVAR_NAME=playbook.dev

HOST_ALMALINUX=almalinux.home
HOST_DEBIAN=debian.home
HOST_MINT=mint.home
HOST_UBUNTU=ubuntu.home

HOSTS_USER=ansible-user
HOSTS_USER_PASS=secret-password
ANSIBLE_PLAYBOOK_ASK_VAULT_PASS=false

export HOST_ALMALINUX \
  HOST_DEBIAN \
  HOST_MINT \
  HOST_UBUNTU \
  HOSTS_USER \
  HOSTS_USER_PASS \
  ANSIBLE_PLAYBOOK_ASK_VAULT_PASS
