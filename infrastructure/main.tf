provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  location     = var.location
}

module "volume" {
  source = "./modules/volume"

  project_name = var.project_name
  location     = var.location
  size         = var.volume_size_gb
}

module "server" {
  source = "./modules/server"

  project_name = var.project_name
  server_type  = var.server_type
  location     = var.location
  ssh_key_ids  = var.ssh_key_ids
  network_id   = module.network.network_id
  subnet_id    = module.network.subnet_id
  firewall_id  = module.network.firewall_id
  volume_id    = module.volume.volume_id
}

module "dns" {
  source = "./modules/dns"

  domain      = var.domain
  zone_id     = var.cloudflare_zone_id
  server_ipv4 = module.server.ipv4_address
  server_ipv6 = module.server.ipv6_address
  subdomains  = var.subdomains
}
