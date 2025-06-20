variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "kubetyper"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "region" {
  description = "DigitalOcean region for resources"
  type        = string
  default     = "nyc3"
}

variable "cluster_version" {
  description = "Kubernetes version for the DOKS cluster"
  type        = string
  default     = "1.29.1-do.0"
}

variable "node_pool_size" {
  description = "Size of the node pool for the Kubernetes cluster"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
  
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "auto_scale" {
  description = "Enable auto-scaling for the node pool"
  type        = bool
  default     = true
}

variable "min_nodes" {
  description = "Minimum number of nodes when auto-scaling is enabled"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of nodes when auto-scaling is enabled"
  type        = number
  default     = 6
}

variable "db_engine" {
  description = "Database engine for the managed database"
  type        = string
  default     = "pg"
}

variable "db_version" {
  description = "Database version"
  type        = string
  default     = "15"
}

variable "db_size" {
  description = "Database droplet size"
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "db_node_count" {
  description = "Number of nodes in the database cluster"
  type        = number
  default     = 1
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
  default     = "kubetyper"
}

variable "db_user" {
  description = "Username for the database"
  type        = string
  default     = "kubetyper"
}

variable "ssh_key_name" {
  description = "Name of the SSH key in DigitalOcean for cluster access"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["kubetyper", "managed-by-terraform"]
} 