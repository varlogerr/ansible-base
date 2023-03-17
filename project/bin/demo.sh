#!/usr/bin/env bash

PROJ_BINDIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"

CORE_BINDIR=""
CORE_DIR=""
_iife_detect_core_dirs() {
  # detect first found symlink real directory.
  # it's assumed that PROJ_BINDIR contains symlinks
  # to binaries from CORE_BINDIR and no other symlinks
  local found_symlink; found_symlink="$(
    find "${PROJ_BINDIR}" -name '*.sh' -type l \
      | sort -n | head -n 1
  )"
  [[ -n "${found_symlink}" ]] || {
    echo "[fatal] Can't detect symlink to core binary" >&2
    return 1
  }

  CORE_BINDIR="$(dirname -- "$(realpath -- "${found_symlink}" 2>/dev/null)")" || {
    echo "[fatal] Can't detect CORE_BINDIR" >&2
    return 1
  }
  CORE_DIR="$(realpath -- "${CORE_BINDIR}/.." 2>/dev/null)"  || {
    echo "[fatal] Can't detect CORE_DIR" >&2
    return 1
  }
}; _iife_detect_core_dirs && unset _iife_detect_core_dirs || {
  exit 1
}

declare -r CORE_BINDIR CORE_DIR PROJ_BINDIR
export PROJ_BINDIR

. "${CORE_DIR}/system/inc/shell/bootstrap.sh"

#
# Do whatever you're supposed to do
#

# just a demo
text_decore "
 .
  CORE_BINDIR         : ${CORE_BINDIR}
  CORE_DIR            : ${CORE_DIR}
  PROJ_BINDIR         : ${PROJ_BINDIR}
  ANSIBLE_ROLES_PATH  : ${ANSIBLE_ROLES_PATH}
 .
" | log_info
