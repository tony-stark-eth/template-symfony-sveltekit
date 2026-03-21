variable "domain" {
  description = "Root-Domain (z.B. example.com)"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare Zone ID für die Domain"
  type        = string
}

variable "server_ipv4" {
  description = "Öffentliche IPv4-Adresse des Servers"
  type        = string
}

variable "server_ipv6" {
  description = "Öffentliche IPv6-Adresse des Servers"
  type        = string
}

variable "subdomains" {
  description = "Subdomains die auf den Server zeigen (z.B. ['app', 'api', 'errors', 'ntfy'])"
  type        = list(string)
}
