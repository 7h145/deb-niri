#!/bin/bash
# vim:et:ai:sw=2:tw=0:ft=bash
# copyright 2025 <github.attic@typedef.net>, CC BY 4.0

cleanup() {
  # cache mounts/build cache
  podman builder prune

  # untagged/intermediate layers
  podman image prune
}

ARGV=(
  # build the 'artifacts' stage
  '--target=artifacts'

  # export files to $PWD
  '--output' "type=local,dest=${PWD}/artifacts"
)

mkdir -vp artifacts
podman build ${ARGV:+"${ARGV[@]}"} "${@}" "${0%/*}"

#cleanup

