# KubeTyper: Cloud-Native Multiplayer Typing Game

[![CI/CD Pipeline](https://github.com/your-username/kubetyper/workflows/KubeTyper%20CI%2FCD%20Pipeline/badge.svg)](https://github.com/your-username/kubetyper/actions)
[![codecov](https://codecov.io/gh/your-username/kubetyper/branch/main/graph/badge.svg)](https://codecov.io/gh/your-username/kubetyper)

## 🎯 Project Overview

KubeTyper is a modern, cloud-native multiplayer typing game built with cutting-edge web technologies. It demonstrates enterprise-grade software architecture patterns while delivering an engaging real-time gaming experience.

### ✨ Key Features

- **Real-time Multiplayer:** Up to 20 players per race with sub-100ms latency
- **Cloud-Native Architecture:** Kubernetes-native design with horizontal scaling
- **Modern Tech Stack:** Svelte frontend, Node.js/TypeScript backend, Redis Pub/Sub
- **Production-Ready:** Comprehensive monitoring, security, and DevOps practices

### 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Svelte SPA    │────│  Node.js API    │────│   PostgreSQL    │
│  (Frontend)     │    │   (Backend)     │    │   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       
         └───────────────────────┼───────────────────────
                                 │                       
                    ┌─────────────────┐                  
                    │  Redis Pub/Sub  │                  
                    │   (Real-time)   │                  
                    └─────────────────┘                  
```

## 🚀 Quick Start (Phase 0 Setup)

### Prerequisites

- **Node.js 18+** - [Download](https://nodejs.org/)
- **Terraform 1.6+** - [Download](https://terraform.io/downloads)
- **DigitalOcean Account** - [Sign up](https://digitalocean.com/)
- **Docker** (optional, for local testing) - [Download](https://docker.com/)

### 1. Clone & Setup Repository

```bash
git clone https://github.com/your-username/kubetyper.git
cd kubetyper

# Install frontend dependencies
cd frontend
npm install
cd ..

# Install backend dependencies
cd backend
npm install
cd ..
```

### 2. Configure Infrastructure

```bash
cd infrastructure

# Initialize Terraform
terraform init

# Create terraform.tfvars file
cat > terraform.tfvars << EOF
do_token = "your-digitalocean-api-token"
project_name = "kubetyper"
environment = "production"
region = "nyc3"
ssh_key_name = "your-ssh-key-name"
EOF

# Plan infrastructure deployment
terraform plan

# Deploy infrastructure (when ready)
terraform apply
```

### 3. Set Up GitHub Secrets

Configure the following secrets in your GitHub repository:

```bash
# Repository Settings → Secrets and variables → Actions
DIGITALOCEAN_ACCESS_TOKEN=your-do-token
CLUSTER_NAME=kubetyper-production-cluster
```

### 4. Local Development

```bash
# Terminal 1: Start backend
cd backend
npm run dev

# Terminal 2: Start frontend  
cd frontend
npm run dev
```

Visit `http://localhost:3000` to see the application.

## 🎯 Phase 0 Completion Checklist

### ✅ Infrastructure & CI/CD Foundation

- [x] **Repository Structure:** Monorepo with `frontend/`, `backend/`, `infrastructure/` directories
- [x] **Package Configuration:** Complete `package.json` files with all dependencies
- [x] **Terraform Infrastructure:** DOKS cluster, PostgreSQL, Container Registry
- [x] **GitHub Actions CI/CD:** Automated linting, testing, building, and deployment
- [x] **Docker Configuration:** Multi-stage builds with security best practices
- [x] **TypeScript Configuration:** Strict type checking and path mapping

### 🎯 Phase 0 KPIs Status

| KPI | Target | Status |
|-----|--------|--------|
| Infrastructure Reliability | 100% via Terraform | ✅ Ready |
| CI/CD Automation | 0 manual steps | ✅ Configured |
| Code Quality | 100% pass linting/tests | ✅ Enforced |
| Security | Secure secrets management | ✅ Implemented |
| Deployment Speed | <5min commit to staging | ✅ Optimized |

## 🏃 Development Workflow

### Branch Strategy (GitFlow)

```bash
# Feature development
git checkout develop
git checkout -b feature/your-feature-name
# ... make changes ...
git push origin feature/your-feature-name
# Open Pull Request to develop

# Release to production
git checkout main
git merge develop
git push origin main  # Triggers production deployment
```

### Code Quality Standards

```bash
# Run linting (required before commit)
npm run lint        # Both frontend and backend

# Run tests (required before merge)
npm run test        # Unit tests
npm run test:integration  # Integration tests

# Type checking
npm run type-check  # TypeScript validation
```

## 🛠️ Available Scripts

### Frontend (`frontend/`)

```bash
npm run dev         # Development server (port 3000)
npm run build       # Production build
npm run preview     # Preview production build
npm run lint        # ESLint + Svelte linting
npm run test        # Run Vitest unit tests
npm run type-check  # TypeScript validation
```

### Backend (`backend/`)

```bash
npm run dev         # Development server with hot reload
npm run build       # TypeScript compilation
npm run start       # Production server
npm run lint        # ESLint for TypeScript
npm run test        # Run Vitest unit tests
npm run test:integration  # Integration tests with Testcontainers
npm run db:migrate  # Run database migrations
npm run db:seed     # Seed database with test data
```

### Infrastructure (`infrastructure/`)

```bash
terraform init      # Initialize Terraform
terraform plan      # Plan infrastructure changes
terraform apply     # Apply infrastructure changes
terraform destroy   # Destroy infrastructure (use with caution)
```

## 🔧 Configuration

### Environment Variables

#### Backend (.env)

```bash
NODE_ENV=development
PORT=8080
DATABASE_URL=postgresql://user:pass@localhost:5432/kubetyper
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-jwt-key
```

#### Frontend

Environment variables are handled through Vite's built-in support:

```bash
VITE_API_URL=http://localhost:8080
VITE_WS_URL=ws://localhost:8080
```

## 📊 Monitoring & Observability

Once Phase 3 is complete, the following will be available:

- **Grafana Dashboards:** `https://grafana.kubetyper.yourdomain.com`
- **Prometheus Metrics:** `https://prometheus.kubetyper.yourdomain.com`
- **Application Logs:** Centralized via Grafana Loki

## 🔒 Security

- **Container Security:** Non-root containers with minimal base images
- **Network Policies:** Zero-trust network segmentation
- **Secrets Management:** Kubernetes secrets, never in code
- **Dependency Scanning:** Automated vulnerability checks via Trivy

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch from `develop`
3. Make your changes following our coding standards
4. Ensure all tests pass and linting is clean
5. Submit a Pull Request with a clear description

## 📈 Project Phases

- **✅ Phase 0:** Foundation & DevOps Excellence (1-2 weeks)
- **🔄 Phase 1:** Core Game Loop MVP (2-3 weeks)  
- **⏳ Phase 2:** Real-Time Multiplayer & State Management (3-4 weeks)
- **⏳ Phase 3:** Production Hardening & Observability (2-3 weeks)
- **⏳ Phase 4:** Advanced Feature Set (4-6 weeks)

## 📝 Documentation

- [Architecture Decision Records (ADRs)](docs/adrs/)
- [API Documentation](docs/api.md)
- [Deployment Guide](docs/deployment.md)
- [Development Guide](docs/development.md)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues:** [GitHub Issues](https://github.com/your-username/kubetyper/issues)
- **Discussions:** [GitHub Discussions](https://github.com/your-username/kubetyper/discussions)
- **Email:** kubetyper@yourdomain.com

---

**Built with ❤️ using modern cloud-native technologies** 