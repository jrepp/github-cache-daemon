# Goblet Documentation

Complete guide to deploying and operating Goblet Git caching proxy.

## 📖 Documentation Structure

### New Users
Start here to get Goblet running quickly:
- **[Getting Started](getting-started.md)** - Installation and basic setup
- **[Deployment Patterns](operations/deployment-patterns.md)** - Choose the right architecture

### Security
**⚠️ Read before deploying with private repositories:**
- **[Security Overview](security/README.md)** - Multi-tenant security considerations
- **[Isolation Strategies](security/isolation-strategies.md)** - Technical implementation options
- **[Multi-Tenant Deployment](security/multi-tenant-deployment.md)** - Step-by-step security guide

### Operations
Day-to-day operation and maintenance:
- **[Deployment Patterns](operations/deployment-patterns.md)** - Sidecar, namespace, sharded
- **[Load Testing](operations/load-testing.md)** - Validate capacity and performance
- **[Monitoring](operations/monitoring.md)** - Metrics, dashboards, alerting
- **[Troubleshooting](operations/troubleshooting.md)** - Common issues and solutions

### Architecture
Understanding how Goblet works:
- **[Design Decisions](architecture/design-decisions.md)** - Why things work the way they do
- **[Storage Optimization](architecture/storage-optimization.md)** - Cost-effective tiered storage
- **[Scaling Strategies](architecture/scaling-strategies.md)** - Horizontal and vertical scaling

### Reference
Technical specifications and configurations:
- **[Configuration Reference](reference/configuration.md)** - All configuration options
- **[API Reference](reference/api.md)** - HTTP endpoints and responses
- **[Metrics Reference](reference/metrics.md)** - Prometheus metrics catalog
- **[Testing Guide](operations/testing.md)** - Test coverage and strategies
- **[Release Process](operations/releasing.md)** - How releases are created
- **[Upgrade Guide](operations/upgrading.md)** - Version upgrade procedures

### Additional Resources
- **[Documentation Guide](documentation-guide.md)** - How to navigate these docs
- **[Storage Architecture](architecture/storage-architecture.md)** - Deep dive into storage design

## 🎯 Quick Navigation

### By Role

**Developers**
1. [Getting Started](getting-started.md) → Quick setup
2. [Configuration Reference](reference/configuration.md) → Customize behavior
3. [Troubleshooting](operations/troubleshooting.md) → Fix issues

**Operators**
1. [Deployment Patterns](operations/deployment-patterns.md) → Choose architecture
2. [Load Testing](operations/load-testing.md) → Validate setup
3. [Monitoring](operations/monitoring.md) → Observe production

**Security Teams**
1. [Security Overview](security/README.md) → Understand risks
2. [Isolation Strategies](security/isolation-strategies.md) → Technical options
3. [Multi-Tenant Deployment](security/multi-tenant-deployment.md) → Secure configuration

**Architects**
1. [Design Decisions](architecture/design-decisions.md) → Understand architecture
2. [Scaling Strategies](architecture/scaling-strategies.md) → Plan capacity
3. [Storage Optimization](architecture/storage-optimization.md) → Minimize costs

### By Use Case

**Terraform Cloud / Security Scanning**
1. [Security Overview](security/README.md) → Critical multi-tenant considerations
2. [Sidecar Pattern](operations/deployment-patterns.md#sidecar-pattern) → Recommended deployment
3. [Storage Optimization](architecture/storage-optimization.md) → Reduce costs 60-95%

**CI/CD Pipeline Acceleration**
1. [Getting Started](getting-started.md) → Basic setup
2. [Deployment Patterns](operations/deployment-patterns.md) → Integration options
3. [Load Testing](operations/load-testing.md) → Capacity planning

**Enterprise Multi-Tenant**
1. [Security Overview](security/README.md) → Security requirements
2. [Namespace Isolation](operations/deployment-patterns.md#namespace-isolation) → Enterprise pattern
3. [Compliance Guide](security/compliance.md) → SOC 2, ISO 27001

## 🚀 Common Tasks

### Deploy Goblet

**Single-tenant (simple):**
```bash
kubectl apply -f examples/single-instance.yaml
```
→ See [Getting Started](getting-started.md#production-deployment-sidecar-pattern)

**Multi-tenant (secure):**
```bash
kubectl apply -f examples/kubernetes-sidecar-secure.yaml
```
→ See [Multi-Tenant Deployment](security/multi-tenant-deployment.md)

### Test Performance

```bash
cd loadtest && make start && make loadtest-python
```
→ See [Load Testing](operations/load-testing.md)

### Monitor Production

```bash
kubectl port-forward svc/goblet 8080
curl http://localhost:8080/metrics
```
→ See [Monitoring](operations/monitoring.md)

### Troubleshoot Issues

```bash
kubectl logs deployment/goblet | grep ERROR
```
→ See [Troubleshooting](operations/troubleshooting.md)

## 📊 Decision Guides

### Should I use Goblet?

✅ **Yes, if:**
- High frequency of git operations (> 100/day)
- Same repositories accessed repeatedly
- Network bandwidth or latency concerns
- Need resilience to upstream outages

❌ **No, if:**
- Unique repositories accessed once
- Write-heavy workload (git push)
- Git LFS is primary concern
- Minimal git operations

### Which deployment pattern?

| Pattern | When to Use |
|---------|-------------|
| [Single Instance](operations/deployment-patterns.md#single-instance) | Development, < 1K req/day |
| [Sidecar](operations/deployment-patterns.md#sidecar-pattern) | **Recommended default** - Multi-tenant, Kubernetes |
| [Namespace](operations/deployment-patterns.md#namespace-isolation) | Enterprise, compliance requirements |
| [Sharded](operations/deployment-patterns.md#sharded-cluster) | High traffic > 10K req/day |

### Is my deployment secure?

| Scenario | Secure? | Action |
|----------|---------|--------|
| Single user per instance | ✅ Yes | No action needed |
| Multiple users, sidecar pattern | ✅ Yes | No action needed |
| Multiple users, shared instance | ❌ No | Implement isolation |

→ See [Security Overview](security/README.md)

## 🔍 Search Documentation

Can't find what you need? Try these approaches:

**By topic:**
- **Installation** → [Getting Started](getting-started.md)
- **Security** → [Security Overview](security/README.md)
- **Performance** → [Load Testing](operations/load-testing.md), [Scaling](architecture/scaling-strategies.md)
- **Configuration** → [Configuration Reference](reference/configuration.md)
- **Troubleshooting** → [Troubleshooting Guide](operations/troubleshooting.md)
- **Cost optimization** → [Storage Optimization](architecture/storage-optimization.md)

**By error message:**
- "403 Forbidden" → [Security Overview](security/README.md)
- "High latency" → [Troubleshooting](operations/troubleshooting.md#high-latency)
- "Out of disk space" → [Storage Optimization](architecture/storage-optimization.md)
- "High error rate" → [Troubleshooting](operations/troubleshooting.md#high-error-rate)

## 🆘 Getting Help

**Before asking:**
1. Check [Troubleshooting Guide](operations/troubleshooting.md)
2. Search [GitHub Issues](https://github.com/google/goblet/issues)
3. Review [documentation index](#documentation-structure)

**Where to ask:**
- **Bug reports:** [GitHub Issues](https://github.com/google/goblet/issues)
- **Questions:** [GitHub Discussions](https://github.com/google/goblet/discussions)
- **Security issues:** security@example.com (private)

**What to include:**
- Goblet version
- Deployment pattern
- Error messages or logs
- Steps to reproduce
- What you've tried

## 📚 Additional Resources

**Examples:**
- [`examples/`](../examples/) - Configuration examples and templates
- [`loadtest/`](../loadtest/) - Load testing infrastructure

**Community:**
- [GitHub Repository](https://github.com/google/goblet)
- [Release Notes](../CHANGELOG.md)
- [Contributing Guide](../CONTRIBUTING.md)

**Related Projects:**
- [Git LFS](https://git-lfs.github.com/) - Large file storage
- [Athens](https://github.com/gomods/athens) - Go module proxy
- [Artifactory](https://jfrog.com/artifactory/) - Enterprise artifact repository

## 🗺️ Documentation Roadmap

Recently added:
- ✅ Multi-tenant security guide
- ✅ Storage optimization for AWS/GCP/Azure
- ✅ Load testing infrastructure
- ✅ Deployment pattern guide

Coming soon:
- 📅 Grafana dashboard templates
- 📅 Terraform modules for deployment
- 📅 Advanced caching strategies
- 📅 Performance tuning guide

## 📝 Documentation Standards

This documentation follows these principles:

**Clarity:** Simple language, clear examples
**Completeness:** Cover common scenarios and edge cases
**Currency:** Updated with each release
**Searchability:** Cross-referenced and indexed

**Found an issue?** Please [report it](https://github.com/google/goblet/issues) or submit a PR.

---

**Last updated:** 2025-11-07 | **Version:** 2.0
