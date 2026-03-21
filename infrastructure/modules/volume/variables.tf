variable "project_name" {
  description = "Projektname (wird für Resource-Labels verwendet)"
  type        = string
}

variable "location" {
  description = "Hetzner Location (fsn1 = Falkenstein, nbg1 = Nürnberg, hel1 = Helsinki)"
  type        = string
}

variable "size" {
  description = "Größe des Volumes in GB"
  type        = number
}
