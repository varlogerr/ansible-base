#!/usr/bin/env bash

CORE_HOME="${CORE_HOME-$(realpath -- "$(dirname -- "$(realpath -- "${0}")")/..")}"
PROJ_HOME="${PROJ_HOME-$(realpath -- "$(dirname -- "${0}")/..")}"
export CORE_HOME PROJ_HOME

"${CORE_HOME}/bin/play.sh" "${@}"
