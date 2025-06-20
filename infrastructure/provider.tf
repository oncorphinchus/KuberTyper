terraform {
  required_version = ">= 1.6"
  
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }

  # Backend configuration for state management
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "kubetyper-terraform-state"
  #   key    = "infrastructure/terraform.tfstate"
  #   region = "nyc3"
  #   endpoints = {
  #     s3 = "https://nyc3.digitaloceanspaces.com"
  #   }
  #   skip_credentials_validation = true
  #   skip_metadata_api_check = true
  # }
}

provider "digitalocean" {
  token = var.do_token
}

# Data source for SSH keys (if needed for cluster access)
data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
} 