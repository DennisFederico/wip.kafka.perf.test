#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o posix

boot_timestamp="$(date --iso-8601=ns)"

sysctl -w vm.max_map_count=262144