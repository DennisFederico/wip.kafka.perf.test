variable "project_id" {
  description = "The project ID to host the network in"
}

variable "service_acct_email" {  
  default     = "dfederico-sa@solutionsarchitect-01.iam.gserviceaccount.com"
}

variable "owner_name" {
  default = "dfederico"
  description = "The prefix for all name related"
}

variable "network_name" {
  description = "The name of the VPC network being created"
}

variable "subnet_project" {
  description = "Project of the subnet"
}

variable "vpc_cidr" {
  description = "CIDR of VPC"
}

variable "subnet_cidr" {
  description = "CIDR of the subnet"
}

variable "destroy_all" {
  default = false
  description = "Avoid the destroy in the resource lifecycle"
}

variable "region" {
  default = "europe-west2"
}

variable "zone" {
  default = "europe-west2-c"
}

// VM TYPES AND COUNT
variable "zk_vm_type" {
  default = "e2-medium"
}

variable "zk_vm_count" {
  default = 1
}

//4-8 cpu 16*32 ram
variable "br_vm_type" {
  default = "e2-standard-4"
}

variable "br_vm_count" {
  default = 3
}

variable "sr_vm_type" {
  default = "e2-medium"
}

variable "sr_vm_count" {
  default = 0
}

variable "connect_vm_type" {
  default = "e2-standard-2"
}

variable "connect_vm_count" {
  default = 0
}

variable "ksql_vm_type" {
  default = "e2-standard-4"
}

variable "ksql_vm_count" {
  default = 0
}

variable "c3_vm_type" {
  default = "e2-standard-8"
}

variable "c3_vm_count" {
  default = 0
}

variable "loki_vm_type" {
  default = "e2-standard-2"
}

variable "loki_vm_count" {
  default = 0
}

variable "prometheus_vm_type" {
  default = "e2-standard-4"
}

variable "prometheus_vm_count" {
  default = 0
}

variable "prometheus_container_count" {
  default = 0
}

variable "grafana_vm_type" {
  default = "e2-standard-4"
}

variable "grafana_vm_count" {
  default = 0
}

variable "grafana_container_count" {
  default = 0
}


variable "elasticsearch_vm_type" {
  default = "e2-standard-2"
}

variable "kibana_vm_type" {
  default = "e2-standard-2"
}

variable "lag_exporter_vm_type" {
  default = "e2-standard-2"
}

variable "lag_exporter_vm_count" {
  default = 0
}

variable "extra_vm_type" {
  default = "e2-standard-4"
}

variable "extra_vm_count" {
  default = 0
}

variable "extra_vm_tags" {
  description = "tags for network rules to apply"
  default = []
}

variable "spin_elasticsearch" {
  type = bool
  default = false
}

variable "spin_kibana" {
  type = bool
  default = false
}

variable "external_source_ranges" {
  description = "List of IP CIDR ranges external access rule, defaults to 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vm_os_image" {
  //debian-cloud/debian-9
  //debian-cloud/debian-10
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}