output "volume_id" {
  description = "ID des Hetzner Volumes"
  value       = hcloud_volume.data.id
}
