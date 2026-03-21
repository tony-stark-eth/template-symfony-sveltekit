terraform {
  required_version = ">= 1.9"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.33"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # State Backend — MUSS vor dem ersten `tofu apply` konfiguriert werden!
  # Ohne Remote-State ist der State nur lokal und geht bei Server-Wechsel verloren.
  # Empfohlen: Hetzner Object Storage als S3-Backend.
  # backend "s3" {
  #   bucket                      = "your-project-tfstate"
  #   key                         = "prod/terraform.tfstate"
  #   region                      = "eu-central-1"
  #   endpoint                    = "https://fsn1.your-objectstorage.com"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  #   skip_metadata_api_check     = true
  # }
}
