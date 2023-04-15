#!/usr/bin/env bash

#
# TODO:
# * make the file executable in order to be run it
# * modify the file up to your needs
#

{ # Define variables required by bootstrap.sh
  PROJ_HOME="${PROJ_HOME-$(realpath -- "$(dirname -- "${0}")/.." 2>/dev/null)}" || {
    echo "[fatal] Can't detect PROJ_HOME" >&2
    exit 1
  }
  CORE_HOME="${CORE_HOME-$(cd "${PROJ_HOME}" 2>/dev/null && realpath -- "$(
    set -o pipefail
    grep -- '^\s*core_home\s*=' project.conf 2>/dev/null \
    | head -n 1 | cut -d= -f2- | sed -e 's/^\s*//' -e 's/\s*$//'
  )" 2>/dev/null)}" || {
    echo "[fatal] Can't detect core_home in ${PROJ_HOME}/project.conf" >&2
    exit 1
  }
  declare -r CORE_HOME PROJ_HOME
}

{ # Source shlib.sh to have access to it's functions and bootstrap.sh to enrich environment
  . "${CORE_HOME}/system/inc/shell/lib/shlib.sh"
  . "${CORE_HOME}/system/inc/shell/bootstrap.sh"
}

{ # Export vars for play.sh and execute it
  export CORE_HOME PROJ_HOME
  "${CORE_HOME}/bin/play.sh" "${@}"
}
