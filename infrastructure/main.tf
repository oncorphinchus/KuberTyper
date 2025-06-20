# Create a VPC for network isolation
resource "digitalocean_vpc" "main" {
  name     = "${var.project_name}-${var.environment}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"
}

# Create the DigitalOcean Kubernetes cluster (DOKS)
resource "digitalocean_kubernetes_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-cluster"
  region   = var.region
  version  = var.cluster_version
  vpc_uuid = digitalocean_vpc.main.id
  
  # Configure node pool with auto-scaling
  node_pool {
    name       = "${var.project_name}-worker-pool"
    size       = var.node_pool_size
    node_count = var.node_count
    
    auto_scale = var.auto_scale
    min_nodes  = var.auto_scale ? var.min_nodes : null
    max_nodes  = var.auto_scale ? var.max_nodes : null
    
    labels = {
      environment = var.environment
      service     = "kubetyper"
    }
    
    taint {
      key    = "workload"
      value  = "general"
      effect = "NoSchedule"
    }
  }
  
  tags = var.tags
  
  # Destroy grace period
  destroy_all_associated_resources = true
}

# Create managed PostgreSQL database cluster
resource "digitalocean_database_cluster" "main" {
  name       = "${var.project_name}-${var.environment}-db"
  engine     = var.db_engine
  version    = var.db_version
  size       = var.db_size
  region     = var.region
  node_count = var.db_node_count
  
  private_network_uuid = digitalocean_vpc.main.id
  
  tags = var.tags
}

# Create the main application database
resource "digitalocean_database_db" "main" {
  cluster_id = digitalocean_database_cluster.main.id
  name       = var.db_name
}

# Create database user for the application
resource "digitalocean_database_user" "main" {
  cluster_id = digitalocean_database_cluster.main.id
  name       = var.db_user
}

# Create container registry for Docker images
resource "digitalocean_container_registry" "main" {
  name                   = "${var.project_name}-registry"
  subscription_tier_slug = "starter" # Free tier with 500MB storage
  region                 = var.region
}

# Create container registry Docker credentials
resource "digitalocean_container_registry_docker_credentials" "main" {
  registry_name = digitalocean_container_registry.main.name
}

# Create a project to organize resources
resource "digitalocean_project" "main" {
  name        = "${var.project_name}-${var.environment}"
  description = "KubeTyper - Cloud-native multiplayer typing game"
  purpose     = "Web Application"
  environment = title(var.environment)
  
  resources = [
    digitalocean_kubernetes_cluster.main.urn,
    digitalocean_database_cluster.main.urn,
    digitalocean_container_registry.main.urn,
  ]
}

# Create database firewall to allow cluster access
resource "digitalocean_database_firewall" "main" {
  cluster_id = digitalocean_database_cluster.main.id
  
  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.main.id
  }
  
  # Allow connections from the VPC
  rule {
    type  = "ip_addr"
    value = digitalocean_vpc.main.ip_range
  }
}

# Local file for kubeconfig (for CI/CD)
resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.main.kube_config.0.raw_config
  filename = "${path.module}/kubeconfig"
  
  file_permission = "0600"
} 