project_id = "solutionsarchitect-01"
service_acct_email = "dfederico-sa@solutionsarchitect-01.iam.gserviceaccount.com"
subnet_project = "demo"
vpc_cidr = "10.0.0.0/8"
subnet_cidr = "10.10.0.0/16"
owner_name = "dfederico"
network_name = "dfederico-vpc"
region = "europe-west1"
zone = "europe-west1-c"
external_source_ranges = ["213.77.180.0/24", "90.75.217.0/24"]

zk_vm_count = 1
br_vm_count = 1
sr_vm_count = 1
connect_vm_count = 1
ksql_vm_count = 1
c3_vm_count = 1
loki_vm_count = 0
prometheus_vm_count = 0
grafana_vm_count = 0
lag_exporter_vm_count = 0

//vm_os_image = debian-cloud/debian-9 | debian-cloud/debian-10 | default = ubuntu-os-cloud/ubuntu-2004-lts
//zk_vm_type = "e2-standard-2"
//br_vm_type = "e2-standard-4"
//sr_vm_type = "e2-standard-2"
//c3_vm_type = "e2-standard-16"
//prometheus_vm_type = "e2-standard-48"
//grafana_vm_type = "e2-standard-48"
