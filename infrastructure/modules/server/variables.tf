variable "project_name" {
  description = "Projektname (wird für Resource-Labels verwendet)"
  type        = string
}

variable "server_type" {
  description = "Hetzner Server-Typ (z.B. cx23, cx33, cx43)"
  type        = string
}

variable "location" {
  description = "Hetzner Location (fsn1 = Falkenstein, nbg1 = Nürnberg, hel1 = Helsinki)"
  type        = string
}

variable "ssh_key_ids" {
  description = "Liste der Hetzner SSH Key IDs für Server-Zugang"
  type        = list(number)
}

variable "network_id" {
  description = "ID des Hetzner VPC Networks"
  type        = string
}

variable "subnet_id" {
  description = "ID des Hetzner Network Subnets"
  type        = string
}

variable "firewall_id" {
  description = "ID der Hetzner Firewall"
  type        = string
}

variable "volume_id" {
  description = "ID des Hetzner Volumes für Datenpersistenz"
  type        = string
}
