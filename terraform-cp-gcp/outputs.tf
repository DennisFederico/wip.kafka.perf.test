output "subnet" {
  value = "Subnet ${google_compute_subnetwork.subnetwork.name}"
}

output "zookeepers" {
  value = [ for compute in google_compute_instance.zookeeper[*] : "${compute.name}:${compute.network_interface.0.network_ip}" ]  
}
output "brokers" {
  value = [ for compute in google_compute_instance.brokers[*] : "${compute.name}:${compute.network_interface.0.network_ip}" ]  
}
output "schema_registry" {
  value = [ for compute in google_compute_instance.schema_registry[*] : "${compute.name}:${compute.network_interface.0.network_ip}" ]  
}
output "kafka_connect" {
  value = [ for compute in google_compute_instance.kafka_connect[*] : "${compute.name}:${compute.network_interface.0.network_ip}" ]  
}
output "ksql" {
  value = [ for compute in google_compute_instance.ksql[*] : "${compute.name}:${compute.network_interface.0.network_ip} / ${compute.network_interface.0.access_config.0.nat_ip}" ]  
}
output "control_center" {
  value = [ for compute in google_compute_instance.control_center[*] : "${compute.name}:${compute.network_interface.0.network_ip} / ${compute.network_interface.0.access_config.0.nat_ip}" ]
}
output "extra" {
  value = [ for compute in google_compute_instance.extra[*] : "${compute.name}:${compute.network_interface.0.network_ip} / ${compute.network_interface.0.access_config.0.nat_ip}" ]
}
# output "extra" {
#   value = [ for compute in google_compute_instance.extra[*] : "${compute.name}:${compute.network_interface.0.network_ip}" ]
# }
output "loki" {
  value = [ for compute in google_compute_instance.loki[*] : "${compute.name}:${compute.network_interface.0.network_ip} / ${compute.network_interface.0.access_config.0.nat_ip}" ]  
}
output "prometheus" {
  value = [ for compute in google_compute_instance.prometheus[*] : "${compute.name}:${compute.network_interface.0.network_ip} / ${compute.network_interface.0.access_config.0.nat_ip}" ]
}
output "grafana" {
  value = [ for compute in google_compute_instance.grafana[*] : "${compute.name}:${compute.network_interface.0.network_ip} / ${compute.network_interface.0.access_config.0.nat_ip}" ]
}