output "network_id" {
  description = "ID des Hetzner VPC Networks"
  value       = hcloud_network.vpc.id
}

output "subnet_id" {
  description = "ID des Hetzner Network Subnets"
  value       = hcloud_network_subnet.app.id
}

output "firewall_id" {
  description = "ID der Hetzner Firewall"
  value       = hcloud_firewall.app.id
}
