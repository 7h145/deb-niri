#!/bin/bash
# vim:et:ai:sw=2:tw=0:ft=bash
# copyright 2026 <github.attic@typedef.net>, CC BY 4.0

REPO='https://github.com/niri-wm/niri'

#COMMIT='b35bcae35b3f9665043c335e55ed5828af77db85'	# 2025-11-29, v25.11.0
COMMIT='8ed0da44d974c32c6877d2f4630c314da0717ecb'	# 2026-04-25, v26.04.0

cleanup() {
  podman builder prune		# remove cache mounts/build cache
  podman image prune		# remove untagged/intermediate layers
}

# treat the first non-option positional parameter as $COMMIT
[[ -n "${1}" && "${1:0:1}" != '-' ]] && {
  COMMIT="${1}"; shift
  echo "using COMMIT='${COMMIT}'" >&2
}

unset ARGV; declare -a ARGV
[[ -n "${REPO}" ]] &&
  ARGV+=( '--build-arg' "REPO=${REPO}" )
[[ -n "${COMMIT}" ]] &&
  ARGV+=( '--build-arg' "COMMIT=${COMMIT}" )

ARGV+=(
  '--target=artifacts'		# build the 'artifacts' stage
  '--output' "type=local,dest=${PWD}/artifacts"
)

mkdir -vp artifacts

# debug
echo podman build ${ARGV:+"${ARGV[@]}"} "${@}" "${0%/*}" >&2

podman build ${ARGV:+"${ARGV[@]}"} "${@}" "${0%/*}"

#cleanup

