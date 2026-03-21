# ── Projekt ───────────────────────────
variable "project_name" {
  description = "Projektname (wird für Resource-Labels verwendet)"
  type        = string
}

# ── Hetzner ───────────────────────────
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Hetzner Server-Typ (z.B. cx31, cx41, cx51)"
  type        = string
  default     = "cx31"
}

variable "location" {
  description = "Hetzner Location (fsn1 = Falkenstein, nbg1 = Nürnberg, hel1 = Helsinki)"
  type        = string
  default     = "fsn1"
}

variable "ssh_key_ids" {
  description = "Liste der Hetzner SSH Key IDs für Server-Zugang"
  type        = list(number)
}

variable "volume_size_gb" {
  description = "Größe des Volumes für DB-Daten in GB"
  type        = number
  default     = 20
}

# ── Cloudflare DNS ────────────────────
variable "cloudflare_api_token" {
  description = "Cloudflare API Token (Zone:DNS:Edit)"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID für die Domain"
  type        = string
}

variable "domain" {
  description = "Root-Domain (z.B. example.com)"
  type        = string
}

variable "subdomains" {
  description = "Subdomains die auf den Server zeigen (z.B. ['app', 'api', 'errors', 'ntfy'])"
  type        = list(string)
  default     = ["app"]
}
