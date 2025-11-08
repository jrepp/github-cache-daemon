# Getting Started with Goblet

Goblet is a Git caching proxy that accelerates repository operations by serving frequently accessed content from a local cache. This guide will help you deploy Goblet safely and efficiently.

## Prerequisites

- Go 1.21 or later
- Git 2.30 or later
- Docker (optional, for containerized deployment)
- Kubernetes (optional, for production deployment)

## Understanding Goblet's Architecture

Goblet sits between Git clients and upstream Git servers (like GitHub), caching repository data to reduce network traffic and improve performance:

```
Git Client → Goblet Proxy → Upstream (GitHub)
                ↓
            Local Cache
```

**Key benefits:**
- 5-20x faster for cached operations
- 80% reduction in network egress
- Resilient to upstream outages
- Read-only operations only

## Quick Start: Single User

For development or single-user scenarios:

```bash
# Build Goblet
git clone https://github.com/google/goblet
cd goblet
go build ./goblet-server

# Run locally
./goblet-server --port 8080 --cache_root /var/cache/goblet

# Configure git to use the proxy
git config --global http.proxy http://localhost:8080

# Test with a repository
git clone https://github.com/kubernetes/kubernetes.git
```

Subsequent clones of the same repository will be served from cache.

## Production Deployment: Sidecar Pattern

For production use with private repositories, deploy Goblet as a sidecar container. This provides perfect isolation with no additional configuration:

```bash
# Build container image
docker build -t goblet:v1.0 .

# Deploy to Kubernetes
kubectl create namespace goblet
kubectl apply -f examples/kubernetes-sidecar.yaml

# Verify deployment
kubectl get pods -n goblet
kubectl logs -f deployment/goblet -c goblet-cache
```

The sidecar pattern ensures each workload has its own isolated cache, preventing any data leakage between users or tenants.

## Configuration

### Basic Configuration

```bash
# Command-line flags
goblet-server \
  --port 8080 \
  --cache_root /var/cache/goblet \
  --upstream_timeout 30s
```

### Environment Variables

```bash
export GOBLET_PORT=8080
export GOBLET_CACHE_ROOT=/var/cache/goblet
export GOBLET_LOG_LEVEL=info
```

### Authentication

Goblet supports OAuth2 and OIDC for authentication:

```bash
# OAuth2 (Google)
goblet-server \
  --auth_type oauth2 \
  --oauth2_client_id your-client-id

# OIDC
goblet-server \
  --auth_type oidc \
  --oidc_issuer https://auth.example.com \
  --oidc_client_id goblet
```

## Verifying Your Deployment

### Health Check

```bash
curl http://localhost:8080/healthz
# Expected: HTTP 200 OK
```

### Metrics

```bash
curl http://localhost:8080/metrics
# Returns Prometheus-formatted metrics
```

### Test Cache Functionality

```bash
# Clone a repository twice
time git clone https://github.com/golang/go.git go-first
rm -rf go-first

time git clone https://github.com/golang/go.git go-second
rm -rf go-second

# Second clone should be significantly faster
```

## Next Steps

### For Single-User Deployments

- Review [Configuration Reference](reference/configuration.md)
- Set up [Monitoring](operations/monitoring.md)
- Configure [Storage Optimization](architecture/storage-optimization.md)

### For Multi-Tenant Deployments

**⚠️ Important:** Multi-tenant deployments with private repositories require additional security configuration.

1. Read [Security Overview](security/README.md)
2. Choose an [Isolation Strategy](security/isolation-strategies.md)
3. Follow [Multi-Tenant Deployment Guide](security/multi-tenant-deployment.md)

### For Production Operations

- Review [Deployment Patterns](operations/deployment-patterns.md)
- Set up [Load Testing](operations/load-testing.md)
- Configure [Monitoring and Alerting](operations/monitoring.md)
- Review [Troubleshooting Guide](operations/troubleshooting.md)

## Common Use Cases

### CI/CD Pipeline Acceleration

Deploy Goblet as a shared cache for your CI/CD runners:

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    env:
      HTTP_PROXY: http://goblet.internal:8080
      HTTPS_PROXY: http://goblet.internal:8080
    steps:
      - uses: actions/checkout@v3
      - run: go test ./...
```

### Terraform Module Caching

Deploy Goblet as a sidecar to cache Terraform modules:

```hcl
# Configure git to use proxy
resource "null_resource" "configure_git" {
  provisioner "local-exec" {
    command = "git config --global http.proxy http://localhost:8080"
  }
}
```

### Development Environment

Use Goblet locally to speed up development:

```bash
# Start Goblet in Docker
docker run -d -p 8080:8080 \
  -v /var/cache/goblet:/cache \
  goblet:latest

# Configure git
git config --global http.proxy http://localhost:8080
```

## Understanding Cache Behavior

### What Gets Cached

- Repository objects (commits, trees, blobs)
- References (branches, tags)
- Pack files

### What Doesn't Get Cached

- Write operations (push, etc.)
- Git LFS objects
- Authentication tokens

### Cache Freshness

Goblet automatically updates cached references when:
- A client requests newer refs than cached
- The cache is older than 5 minutes (configurable)

During upstream outages, Goblet serves stale cache with appropriate warnings.

## Resource Requirements

### Minimum Requirements

- CPU: 1 core
- Memory: 1GB
- Disk: 10GB (varies by cached repositories)
- Network: 100Mbps

### Recommended for Production

- CPU: 2-4 cores
- Memory: 4-8GB
- Disk: 100GB+ SSD
- Network: 1Gbps

### Scaling Guidelines

| Requests/day | Recommended Setup | Cache Size |
|--------------|-------------------|------------|
| < 1,000 | Single instance | 10-50GB |
| 1,000-10,000 | Single instance + SSD | 50-200GB |
| 10,000-100,000 | Multiple instances (sharded) | 100GB-1TB |
| > 100,000 | Sidecar pattern + auto-scaling | 10GB per pod |

## Getting Help

- **Documentation:** [docs/](index.md)
- **Issues:** https://github.com/google/goblet/issues
- **Discussions:** https://github.com/google/goblet/discussions

## Security Notice

⚠️ **Important for Multi-Tenant Deployments:**

If multiple users with different access permissions will share a Goblet instance, you must implement proper tenant isolation. The default configuration does not provide multi-tenant security.

**Safe default deployments:**
- Single user/service account per instance
- Public repositories only
- Sidecar pattern (one instance per workload)

For multi-tenant scenarios, see [Security Documentation](security/README.md).
