// Configure the Google Cloud provider
provider "google" {
  credentials = file("gcloud-key.json")
  project     = var.project_id
  region      = var.region
}

provider "google-beta" {
  credentials = file("gcloud-key.json")
  project     = var.project_id
  region      = var.region
}

locals {
  actual_subnet = "${var.network_name}-${var.subnet_project}-subnet"
  prometheus_config_path   = "/etc/prometheus/prometheus.yml"
  kafka_lag_exporter_config_path = "/etc/kafka_lag_exporter/"
}

module "prometheus-container" {
  source = "terraform-google-modules/container-vm/google"

  //cos_image_name = var.cos_image_name

  container = {
    //image = "marketplace.gcr.io/google/prometheus:2.18"
    image = "gcr.io/cloud-marketplace/google/prometheus2:2.30"
    volumeMounts = [
      {
        mountPath = "/etc/prometheus/prometheus.yml"
        name      = "prometheus-config"
        readOnly  = false
      }
    ]
  }

  volumes = [
    {
      name = "prometheus-config"
      hostPath = {
        path = local.prometheus_config_path
      }
    }
  ]

  restart_policy = "Always"
} 

module "grafana-container" {
  source = "terraform-google-modules/container-vm/google"

  //cos_image_name = var.cos_image_name

  container = {
    //image = "marketplace.gcr.io/google/prometheus/grafana:2.18"
    image = "gcr.io/cloud-marketplace/google/grafana7:7.4"
  }

  restart_policy = "Always"
}

module "elasticsearch-container" {
  source = "terraform-google-modules/container-vm/google"

  //cos_image_name = var.cos_image_name

  container = {
    //image = "docker.elastic.co/elasticsearch/elasticsearch:8.2.3"
    image = "docker.elastic.co/elasticsearch/elasticsearch:7.17.4"
    //image = "docker.elastic.co/elasticsearch/elasticsearch:7.8.1"
    //image = "gcr.io/cloud-marketplace/google/elasticsearch7:7.10"
    env = [
      {
        name = "discovery.type"
        value = "single-node"
      }
      ,
      { //XPACK_SECURITY_ENABLED
        name = "xpack.security.enabled"        
        value = "true"
      }
      # ,
      # {
      #   name = "xpack.security.http.ssl.enabled"
      #   value = "false"
      # }      
      ,
      {
        name = "ELASTIC_PASSWORD"
        value = "elasticpass"
      }
      ,
      {
        name = "ES_JAVA_OPTS"
        value = "-Xms4g -Xmx4g"
      }

    ]
  }

  restart_policy = "Always"
}

module "kibana-container" {
  source = "terraform-google-modules/container-vm/google"

  //cos_image_name = var.cos_image_name

  container = {
    //image = "docker.elastic.co/kibana/kibana:8.2.3"
    image = "docker.elastic.co/kibana/kibana:7.17.4"
    //image = "docker.elastic.co/kibana/kibana:7.8.1"
    //image = "gcr.io/cloud-marketplace/google/elasticsearch7:7.10"
    env = [
      {
        //MIND THE PROTOCOL HTTP(S)
        name = "ELASTICSEARCH_HOSTS"
        value = "http://${var.owner_name}-${var.subnet_project}-elasticsearch:9200"
      }
      # ,
      # {
      #   name = "SERVER_NAME"
      #   value = "${var.subnet_project}-kibana"
      # }
      ,
      {
        name = "elasticsearch.ssl.verificationMode"
        value = "none"
      }
      ,
      {
        name = "ELASTICSEARCH_SSL_VERIFICATIONMODE"
        value = "none"
      }
      ,
      {
        name = "ELASTICSEARCH_USERNAME"
        value = "elastic"
      }
      ,
      {
        name = "ELASTICSEARCH_PASSWORD"
        value = "elasticpass"
      }
      // FROM v.8.1 you need to setup the password for kibana user
      //curl -u elastic -XPOST -H "Content-Type: application/json" https://project-demo-elasticsearch:9200/_security/user/kibana/_password -d "{ \"password\": \"kibanapass\" }"
    ]
  }

  restart_policy = "Always"
}

module "lag_exporter-container" {
  source = "terraform-google-modules/container-vm/google"

  container = {
    //image = "marketplace.gcr.io/google/prometheus/grafana:2.18"
    image = "lightbend/kafka-lag-exporter:0.6.8"
    volumeMounts = [
      {
        mountPath = "/opt/docker/conf/"
        name      = "kafka_lag_exporter-config"
        readOnly  = false
      }
    ]
  }

  volumes = [
    {
      name = "kafka_lag_exporter-config"
      hostPath = {
        path = local.kafka_lag_exporter_config_path
      }
    }
  ]

  restart_policy = "Never"
} 

resource "google_compute_subnetwork" "subnetwork" {
  network        = var.network_name
  project        = var.project_id  
  region         = var.region
  ip_cidr_range  = var.subnet_cidr
  name           = local.actual_subnet
}

// Zookeepers
resource "google_compute_instance" "zookeeper" {
  count = var.zk_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-zk-${count.index}"
  machine_type = var.zk_vm_type
  zone         = var.zone
  //hostname     = "zk-${count.index}.${var.subnet_project}.${var.owner_name}"

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 100
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
  }
  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

resource "google_compute_disk" "brokers-data-disk" {
  count = var.br_vm_count
  name  = "broker-data-disk-${var.subnet_project}-${count.index}"
  type  = "pd-standard"
  size  = 2000 # 1TB in GB
  zone  = "${var.zone}"
}

// Brokers
resource "google_compute_instance" "brokers" {
  count        = var.br_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-broker-${count.index}"
  machine_type = var.br_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 300
    }
  }

  attached_disk {
    source = google_compute_disk.brokers-data-disk[count.index].self_link
    device_name = "broker-data-disk-${var.subnet_project}-${count.index}"
  }

  network_interface {
    subnetwork = local.actual_subnet
    # access_config {
    #   // Include this section to give the VM an external ip address
    # }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-brokers"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}


resource "null_resource" "mount_disks" {
  count        = var.br_vm_count

  triggers = {
    instance_id = google_compute_instance.brokers[count.index].id
    disk_id     = google_compute_disk.brokers-data-disk[count.index].id
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /mnt/kafka-data",
      "sudo mkfs.ext4 /dev/sdb",    # Replace /dev/sdb with the appropriate disk identifier
      "sudo mount /dev/sdb /mnt/kafka-data",
      "echo '/dev/sdb /mnt/kafka-data ext4 defaults 0 0' | sudo tee -a /etc/fstab",
    ]

    connection {
      type                = "ssh"
      bastion_host        = "34.147.151.76" #google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
      bastion_user        = "dfederico"
      bastion_private_key = file("~/.ssh/id_rsa")
      host                = google_compute_instance.brokers[count.index].network_interface[0].network_ip
      user                = "dfederico"
      private_key         = file("~/.ssh/id_rsa") # Replace with your private key path
    }
  }
}

# resource "google_compute_instance_attach_disk" "broker-disk-attachment" {
#   count = var.br_vm_count
#   instance = google_compute_instance.brokers[count.index].id
#   disk     = google_compute_disk.broker-data-disks[count.index].id
# }

// Schema Registry
resource "google_compute_instance" "schema_registry" {
  count        = var.sr_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-sr-${count.index}"
  machine_type = var.sr_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    # access_config {
    #   // Include this section to give the VM an external ip address
    # }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-sr"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// Connect
resource "google_compute_instance" "kafka_connect" {
  count        = var.connect_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-connect-${count.index}"
  machine_type = var.connect_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    # access_config {
    #   // Include this section to give the VM an external ip address
    # }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-connect"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// KSQL
resource "google_compute_instance" "ksql" {
  count        = var.ksql_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-ksql-${count.index}"
  machine_type = var.ksql_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 300
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  tags = ["${var.owner_name}-${var.subnet_project}-ksql"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// Control Center
resource "google_compute_instance" "control_center" {
  count        = var.c3_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-c3-${count.index}"
  machine_type = var.c3_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 150
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-c3"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

data "local_file" "fetch_prometheus_config" {
    filename = "${path.module}/prometheus/fetch_prometheus_config.sh"
}

data "local_file" "prometheus_config" {
    filename = "${path.module}/prometheus/prometheus_config.sh"
}

data "template_file" "prometheus_config_tpl" {
  template = file("prometheus/prometheus_config.sh.tpl")
  vars = {
    config_path   = local.prometheus_config_path
  }
}

data "local_file" "increase_vm_config" {
    filename = "${path.module}/elasticsearch/increasevm.sh"
}

// Loki
resource "google_compute_instance" "loki" {
  count        = var.loki_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-loki"
  machine_type = var.c3_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 150
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-loki"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// Prometheus
resource "google_compute_instance" "prometheus-container" {
  count        = var.prometheus_container_count
  name         = "${var.owner_name}-${var.subnet_project}-prometheus-${count.index}"
  machine_type = var.prometheus_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.prometheus-container.source_image
      size  = 50
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-prometheus"]

  metadata = {
    gce-container-declaration = module.prometheus-container.metadata_value
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
    google-logging-enabled    = "false"
    google-monitoring-enabled = "false"
    prometheus-yml = "${file("prometheus/prometheus.yml")}"
  }

  metadata_startup_script = data.local_file.fetch_prometheus_config.content

  labels = {
    container-vm = module.prometheus-container.vm_container_label
  }
  
  service_account {
    email = var.service_acct_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

resource "google_compute_instance" "prometheus" {
  count        = var.prometheus_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-prometheus-${count.index}"
  machine_type = var.prometheus_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 300
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  tags = ["${var.owner_name}-${var.subnet_project}-prometheus"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// Grafana
resource "google_compute_instance" "grafana-container" {
  count        = var.grafana_container_count
  name         = "${var.owner_name}-${var.subnet_project}-grafana-${count.index}"
  machine_type = var.grafana_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.grafana-container.source_image
      size  = 50
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-grafana"]

  metadata = {
    gce-container-declaration = module.grafana-container.metadata_value
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
    google-logging-enabled    = "false"
    google-monitoring-enabled = "false"
  }

  labels = {
    container-vm = module.grafana-container.vm_container_label
  }
  
  service_account {
    email = var.service_acct_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

resource "google_compute_instance" "grafana" {
  count        = var.grafana_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-grafana-${count.index}"
  machine_type = var.grafana_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 300
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  tags = ["${var.owner_name}-${var.subnet_project}-grafana"]

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

data "local_file" "fetch_lag_exporter_config" {
    filename = "${path.module}/kafka-lag-exporter/fetch_lag_exporter_config.sh"
}

// Elasticsearch
resource "google_compute_instance" "elasticsearch" {
  count        = var.spin_elasticsearch == true ? 1 : 0
  name         = "${var.owner_name}-${var.subnet_project}-elasticsearch"
  machine_type = var.elasticsearch_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.elasticsearch-container.source_image
      size  = 150
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-elasticsearch"]

  metadata = {
    gce-container-declaration = module.elasticsearch-container.metadata_value
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
    google-logging-enabled    = "false"
    google-monitoring-enabled = "false"
  }

  metadata_startup_script = data.local_file.increase_vm_config.content
  labels = {
    container-vm = module.elasticsearch-container.vm_container_label
  }
  
  service_account {
    email = var.service_acct_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// Kibana
resource "google_compute_instance" "kibana" {
  count        = var.spin_kibana == true ? 1 : 0
  name         = "${var.owner_name}-${var.subnet_project}-kibana"
  machine_type = var.kibana_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.kibana-container.source_image
      size  = 50
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  tags = ["${var.owner_name}-${var.subnet_project}-kibana"]

  metadata = {
    gce-container-declaration = module.kibana-container.metadata_value
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
    google-logging-enabled    = "false"
    google-monitoring-enabled = "false"
  }

  labels = {
    container-vm = module.kibana-container.vm_container_label
  }
  
  service_account {
    email = var.service_acct_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// LAG EXPORTER
resource "google_compute_instance" "lag_exporter" {
  count        = var.lag_exporter_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-lag-exporter"
  machine_type = var.lag_exporter_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.lag_exporter-container.source_image
      size  = 50
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
  }
  tags = ["${var.owner_name}-${var.subnet_project}-lag-exporter"]

  metadata = {
    gce-container-declaration = module.lag_exporter-container.metadata_value
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
    google-logging-enabled    = "false"
    google-monitoring-enabled = "false"
    application_conf = "${file("kafka-lag-exporter/application.conf")}"
    logback_xml = "${file("kafka-lag-exporter/logback.xml")}"
    truststore_jks = "${filebase64("kafka-lag-exporter/truststore.jks")}"
  }

  metadata_startup_script = data.local_file.fetch_lag_exporter_config.content

  labels = {
    container-vm = module.lag_exporter-container.vm_container_label
  }
  
  service_account {
    email = var.service_acct_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

locals {
  extra_tags = [for t in var.extra_vm_tags : "${var.owner_name}-${var.subnet_project}-${t}"]
}

// EXTRA VMS
resource "google_compute_instance" "extra" {
  count        = var.extra_vm_count
  name         = "${var.owner_name}-${var.subnet_project}-extra-${count.index}"
  machine_type = var.extra_vm_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.vm_os_image
      size  = 150
    }
  }

  network_interface {
    subnetwork = local.actual_subnet
    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  tags = local.extra_tags

  metadata = {
    ssh-keys = "${var.owner_name}:${file("id_rsa.pub")}"
  }

  depends_on = [ google_compute_subnetwork.subnetwork ]
}

// Firewall
resource "google_compute_firewall" "vpc-allow-all" {
  name          = "${var.owner_name}-${var.subnet_project}-vpc-allow"
  description   = "Allow ingress traffic from internal VPC IP ranges"
  network       = var.network_name
  source_ranges = ["${var.vpc_cidr}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
}

resource "google_compute_firewall" "c3" {
  name          = "${var.owner_name}-${var.subnet_project}-c3-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-c3"]

  allow {
    protocol = "tcp"
    ports    = ["9021"]
  }
}

resource "google_compute_firewall" "loki" {
  name          = "${var.owner_name}-${var.subnet_project}-loki-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-loki"]

  allow {
    protocol = "tcp"
    ports    = ["3100","9096"]
  }
}

resource "google_compute_firewall" "grafana" {
  name          = "${var.owner_name}-${var.subnet_project}-grafana-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-grafana"]

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
}

resource "google_compute_firewall" "prometheus" {
  name          = "${var.owner_name}-${var.subnet_project}-prometheus-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-prometheus"]

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }
}

resource "google_compute_firewall" "postgres" {
  name          = "${var.owner_name}-${var.subnet_project}-postgres-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-postgres"]

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
}

resource "google_compute_firewall" "connect" {
  name          = "${var.owner_name}-${var.subnet_project}-connect-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-connect"]

  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }
}

resource "google_compute_firewall" "sr" {
  name          = "${var.owner_name}-${var.subnet_project}-sr-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-sr"]

  allow {
    protocol = "tcp"
    ports    = ["8083"]
  }
}

resource "google_compute_firewall" "ksql" {
  name          = "${var.owner_name}-${var.subnet_project}-ksql-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-ksql"]

  allow {
    protocol = "tcp"
    ports    = ["8088"]
  }
}

resource "google_compute_firewall" "broker" {
  name          = "${var.owner_name}-${var.subnet_project}-broker-firewall"
  network       = var.network_name
  source_ranges = var.external_source_ranges
  target_tags   = ["${var.owner_name}-${var.subnet_project}-brokers"]

  allow {
    protocol = "all"
    //ports    = ["9021"]
  }
}
