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
  # decisions, decisions.  Default is 'missing'.
  #'--pull=always'
  #'--pull=never'

  # build the 'artifact' stage
  '--target=artifact'

  # export files to $PWD
  '--output' "type=local,dest=${PWD}/artifact"
)

mkdir -vp artifact
podman build ${ARGV:+"${ARGV[@]}"} "${@}" "${0%/*}"

#cleanup

