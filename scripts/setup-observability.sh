#!/bin/bash
# KubeTyper Observability Stack Setup
# Production-ready monitoring and logging infrastructure

set -euo pipefail

echo "🔧 Setting up KubeTyper Observability Stack..."

# Create namespaces
echo "📁 Creating namespaces..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repositories
echo "📦 Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus Stack (includes Grafana, Prometheus, AlertManager)
echo "📊 Installing kube-prometheus-stack..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=15d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=do-block-storage \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=20Gi \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.storageClassName=do-block-storage \
  --set grafana.persistence.size=10Gi \
  --set grafana.adminPassword=kubetyper-admin-2024 \
  --set grafana.service.type=ClusterIP \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName=do-block-storage \
  --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=5Gi \
  --wait

# Install Loki for log aggregation
echo "📋 Installing Loki..."
helm upgrade --install loki grafana/loki \
  --namespace logging \
  --set loki.storage.type=filesystem \
  --set loki.storage.filesystem.directory=/tmp/loki \
  --set persistence.enabled=true \
  --set persistence.storageClassName=do-block-storage \
  --set persistence.size=50Gi \
  --set resources.requests.memory=512Mi \
  --set resources.requests.cpu=100m \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=500m \
  --wait

# Install Grafana Alloy (modern replacement for Promtail)
echo "📤 Installing Grafana Alloy..."
helm upgrade --install grafana-alloy grafana/alloy \
  --namespace logging \
  --set controller.type=daemonset \
  --wait

echo "✅ Observability stack setup complete!"
echo ""
echo "🔗 Access Information:"
echo "Grafana: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "Prometheus: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo "AlertManager: kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093"
echo ""
echo "📊 Grafana Login: admin / kubetyper-admin-2024"
