resource "hcloud_network" "vpc" {
  name     = "${var.project_name}-vpc"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "app" {
  network_id   = hcloud_network.vpc.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "app" {
  name = "${var.project_name}-fw"

  # SSH
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]   # Nach Setup einschränken auf eigene IPs
  }

  # HTTP
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}
