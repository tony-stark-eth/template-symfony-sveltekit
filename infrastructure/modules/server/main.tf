resource "hcloud_server" "app" {
  name        = "${var.project_name}-app"
  server_type = var.server_type
  location    = var.location
  image       = "ubuntu-24.04"
  ssh_keys    = var.ssh_key_ids

  labels = {
    managed_by = "opentofu"
    project    = var.project_name
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = var.network_id
  }

  user_data = file("${path.module}/cloud-init.yml")

  lifecycle {
    ignore_changes = [user_data]   # cloud-init nur beim ersten Boot
  }
}

resource "hcloud_volume_attachment" "data" {
  volume_id = var.volume_id
  server_id = hcloud_server.app.id
  automount = true
}
