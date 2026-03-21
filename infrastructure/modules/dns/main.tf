resource "cloudflare_dns_record" "ipv4" {
  for_each = toset(var.subdomains)

  zone_id = var.zone_id
  name    = each.value
  content = var.server_ipv4
  type    = "A"
  proxied = true
  ttl     = 1     # Auto (proxied)
}

resource "cloudflare_dns_record" "ipv6" {
  for_each = toset(var.subdomains)

  zone_id = var.zone_id
  name    = each.value
  content = var.server_ipv6
  type    = "AAAA"
  proxied = true
  ttl     = 1
}
