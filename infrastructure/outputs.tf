# Kubernetes cluster outputs
output "cluster_id" {
  description = "The ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.id
}

output "cluster_urn" {
  description = "The uniform resource name (URN) of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.urn
}

output "cluster_endpoint" {
  description = "The base URL of the API server on the Kubernetes master node"
  value       = digitalocean_kubernetes_cluster.main.endpoint
}

output "cluster_status" {
  description = "The current status of the cluster"
  value       = digitalocean_kubernetes_cluster.main.status
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster"
  value       = digitalocean_kubernetes_cluster.main.version
}

# Database outputs
output "database_host" {
  description = "The hostname of the database cluster"
  value       = digitalocean_database_cluster.main.host
  sensitive   = true
}

output "database_port" {
  description = "Network port that the database cluster is listening on"
  value       = digitalocean_database_cluster.main.port
}

output "database_name" {
  description = "The name of the default database"
  value       = digitalocean_database_db.main.name
}

output "database_user" {
  description = "The username for the database"
  value       = digitalocean_database_user.main.name
}

output "database_password" {
  description = "The password for the database user"
  value       = digitalocean_database_user.main.password
  sensitive   = true
}

output "database_uri" {
  description = "The full connection URI for the database"
  value       = digitalocean_database_cluster.main.uri
  sensitive   = true
}

# Container registry outputs
output "registry_name" {
  description = "The name of the container registry"
  value       = digitalocean_container_registry.main.name
}

output "registry_endpoint" {
  description = "The URL endpoint of the container registry"
  value       = digitalocean_container_registry.main.endpoint
}

output "registry_server_url" {
  description = "The domain of the container registry"
  value       = digitalocean_container_registry.main.server_url
}

# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = digitalocean_vpc.main.id
}

output "vpc_urn" {
  description = "The uniform resource name (URN) of the VPC"
  value       = digitalocean_vpc.main.urn
}

# Project outputs
output "project_id" {
  description = "The ID of the project"
  value       = digitalocean_project.main.id
}

# Kubeconfig for CI/CD
output "kubeconfig_path" {
  description = "Path to the generated kubeconfig file"
  value       = local_file.kubeconfig.filename
}

# Docker credentials for CI/CD
output "docker_credentials" {
  description = "Docker credentials for the container registry"
  value       = digitalocean_container_registry_docker_credentials.main.docker_credentials
  sensitive   = true
} 