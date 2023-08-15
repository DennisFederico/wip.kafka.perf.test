#!/usr/bin/env bash

#set -o errexit -o nounset -o pipefail -o posix
#boot_timestamp="$(date --iso-8601=ns)"
## TODO: BUILD EACH HOST TYPE INDEPENDENTLY BASE ON THE NAME AND NUMBER OF INSTANCES
## SKIP THE SECTION IF THE INSTANCE COUNT IS <= 0
## CONSIDER MOVING TO A TERRAFORM TEMPLATE TO PICK THE NEEDED PARAMETERS THERE, INSTEAD OF ENV VARS

mkdir -p "/etc/prometheus"
cat > "/etc/prometheus/prometheus2.yml" << EOF
global:
  scrape_interval: 30s
  evaluation_interval: 15s
  scrape_timeout: 30s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "zookeeper"
    static_configs:
      - targets:
          - "dfederico-demo-zk-0:8079"
          - "dfederico-demo-zk-1:8079"
          - "dfederico-demo-zk-2:8079"
          - "dfederico-demo-zk-3:8079"
          - "dfederico-demo-zk-4:8079"
          - "dfederico-demo-zk-5:8079"          
        labels:
          env: "demo"
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+)(:[0-9]+)?'
        replacement: '\${1}'

  - job_name: "kafka-broker"
    static_configs:
      - targets:
          - "dfederico-demo-broker-0:8080"
          - "dfederico-demo-broker-1:8080"
          - "dfederico-demo-broker-2:8080"
          - "dfederico-demo-broker-3:8080"
          - "dfederico-demo-broker-4:8080"
          - "dfederico-demo-broker-5:8080"
        labels:
          env: "demo"
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+)(:[0-9]+)?'
        replacement: '\${1}'

  - job_name: "schema-registry"
    static_configs:
      - targets:
          - "dfederico-demo-sr-0:8078"
        labels:
          env: "demo"
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+)(:[0-9]+)?'
        replacement: '\${1}'

  - job_name: "ksqldb"
    static_configs:
      - targets:
          - "dfederico-demo-ksql-0:8076"
          - "dfederico-demo-ksql-1:8076"
          - "dfederico-demo-ksql-2:8076"
        labels:
          env: "demo"
    relabel_configs:
      - source_labels: [__address__]
        target_label: hostname
        regex: '([^:]+)(:[0-9]+)?'
        replacement: '${1}'
EOF
