#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o posix

boot_timestamp="$(date --iso-8601=ns)"

mkdir -p "/etc/prometheus"

curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/prometheus-yml" -H "Metadata-Flavor: Google" > /etc/prometheus/prometheus.yml
