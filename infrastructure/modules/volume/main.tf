resource "hcloud_volume" "data" {
  name     = "${var.project_name}-data"
  size     = var.size
  location = var.location
  format   = "ext4"

  labels = {
    managed_by = "opentofu"
    project    = var.project_name
  }
}
