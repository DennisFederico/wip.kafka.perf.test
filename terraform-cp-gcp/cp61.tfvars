project_id = "solutionsarchitect-01"
service_acct_email = "dfederico-sa@solutionsarchitect-01.iam.gserviceaccount.com"
subnet_project = "cp61"
vpc_cidr = "10.0.0.0/8"
subnet_cidr = "10.10.0.0/16"
owner_name = "dfederico"
network_name = "dfederico-vpc"
region = "europe-west1"
zone = "europe-west1-c"
external_source_ranges = ["90.75.217.0/24"]

zk_vm_count = 1
br_vm_count = 6
sr_vm_count = 0
connect_vm_count = 0
ksql_vm_count = 0
c3_vm_count = 1
extra_vm_count = 0
loki_vm_count = 0
prometheus_vm_count = 1
grafana_vm_count = 1
prometheus_container_count = 0
grafana_container_count = 0
spin_elasticsearch = false
spin_kibana = false
lag_exporter_vm_count = 0
extra_vm_tags = ["prometheus", "grafana"]

//vm_os_image = debian-cloud/debian-9 | debian-cloud/debian-10 | default = ubuntu-os-cloud/ubuntu-2004-lts
//zk_vm_type = "e2-standard-2"
//br_vm_type = "e2-standard-4"
//sr_vm_type = "e2-standard-2"
//c3_vm_type = "e2-standard-16"
//prometheus_vm_type = "e2-standard-48"
//grafana_vm_type = "e2-standard-48"

//curl -XPOST -H "Content-Type: application/json" https://dfederico-demo-elasticsearch:9200/_security/user/kibana/_password -d "{ \"password\": \"kibanapass\" }"