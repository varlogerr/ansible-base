#!/usr/bin/env bash

CORE_BINDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"

# PROJ_BINDIR must be exported in order to affect play.sh
PROJ_BINDIR="${PROJ_BINDIR-$(realpath -- "$(dirname -- "${0}")")}"
ANSIBLE_PLAYBOOK_STRATEGY=free
export PROJ_BINDIR ANSIBLE_PLAYBOOK_STRATEGY

"${CORE_BINDIR}/play.sh"
