project_id = "my-gcp-project"
service_acct_email = "iam-user@gpc-project.iam.gserviceaccount.com"
subnet_project = "demo"
vpc_cidr = "10.0.0.0/8"
subnet_cidr = "10.10.0.0/16"
owner_name = "iam-user"
network_name = "my-vpc"
region = "europe-west1"
zone = "europe-west1-c"
external_source_ranges = ["123.123.123.0/24", "128.0.0.1"]

zk_vm_count = 1
br_vm_count = 3
sr_vm_count = 1
connect_vm_count = 1
ksql_vm_count = 0
c3_vm_count = 1
extra_vm_count = 0
loki_vm_count = 0
prometheus_vm_count = 0
grafana_vm_count = 0
spin_elasticsearch = false
spin_kibana = false
lag_exporter_vm_count = 0

//vm_os_image = debian-cloud/debian-9 | debian-cloud/debian-10 | default = ubuntu-os-cloud/ubuntu-2004-lts
//zk_vm_type = "e2-standard-2"
//br_vm_type = "e2-standard-4"
//sr_vm_type = "e2-standard-2"
//c3_vm_type = "e2-standard-16"
//prometheus_vm_type = "e2-standard-48"
//grafana_vm_type = "e2-standard-48"

//curl -XPOST -H "Content-Type: application/json" https://xyz-elasticsearch:9200/_security/user/kibana/_password -d "{ \"password\": \"kibanapass\" }"