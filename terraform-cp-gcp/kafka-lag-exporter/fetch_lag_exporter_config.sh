#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o posix

boot_timestamp="$(date --iso-8601=ns)"

mkdir -p "/etc/kafka_lag_exporter"

curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/application_conf" -H "Metadata-Flavor: Google" > /etc/kafka_lag_exporter/application.conf
curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/logback_xml" -H "Metadata-Flavor: Google" > /etc/kafka_lag_exporter/logback.xml
curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/truststore_jks" -H "Metadata-Flavor: Google" | base64 -d > /etc/kafka_lag_exporter/truststore.jks
