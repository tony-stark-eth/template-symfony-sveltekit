output "ipv4_address" {
  description = "Öffentliche IPv4-Adresse des Servers"
  value       = hcloud_server.app.ipv4_address
}

output "ipv6_address" {
  description = "Öffentliche IPv6-Adresse des Servers"
  value       = hcloud_server.app.ipv6_address
}

output "server_id" {
  description = "ID des Hetzner Servers"
  value       = hcloud_server.app.id
}
