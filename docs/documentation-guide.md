# Documentation Guide

This guide helps you navigate Goblet's documentation efficiently.

## 📁 Documentation Structure

```
docs/
├── index.md                          # Start here - Master index
├── getting-started.md                # Quick setup guide
├── code-of-conduct.md                # Community guidelines
├── contributing.md                   # How to contribute
│
├── security/                         # Security documentation
│   ├── README.md                     # Security overview
│   ├── isolation-strategies.md       # Technical isolation guide
│   ├── multi-tenant-deployment.md    # Secure deployment guide
│   ├── threat-model.md               # Security threat analysis
│   └── detailed-guide.md             # Comprehensive security reference
│
├── operations/                       # Day-to-day operations
│   ├── deployment-patterns.md        # Architecture patterns
│   ├── load-testing.md               # Performance validation
│   ├── monitoring.md                 # Observability setup
│   └── troubleshooting.md            # Problem resolution
│
├── architecture/                     # Design and architecture
│   ├── design-decisions.md           # Architectural rationale
│   ├── storage-optimization.md       # Cost-effective storage
│   ├── scaling-strategies.md         # Capacity planning
│   └── secure-multi-tenant-rfc.md    # Security architecture RFC
│
└── reference/                        # Technical specifications
    ├── configuration.md              # Config options
    ├── api.md                        # HTTP API reference
    └── metrics.md                    # Prometheus metrics
```

## 🎯 Finding What You Need

### By Experience Level

**New to Goblet?**
1. [Getting Started](getting-started.md)
2. [Security Overview](security/README.md)
3. [Deployment Patterns](operations/deployment-patterns.md)

**Experienced User?**
1. [Architecture Decisions](architecture/design-decisions.md)
2. [Advanced Configuration](reference/configuration.md)
3. [Scaling Strategies](architecture/scaling-strategies.md)

**Production Operator?**
1. [Deployment Patterns](operations/deployment-patterns.md)
2. [Load Testing](operations/load-testing.md)
3. [Monitoring](operations/monitoring.md)
4. [Troubleshooting](operations/troubleshooting.md)

### By Topic

| Topic | Primary Document | Related Docs |
|-------|------------------|--------------|
| **Setup** | [Getting Started](getting-started.md) | [Deployment Patterns](operations/deployment-patterns.md) |
| **Security** | [Security Overview](security/README.md) | [Isolation](security/isolation-strategies.md), [Multi-Tenant](security/multi-tenant-deployment.md) |
| **Performance** | [Load Testing](operations/load-testing.md) | [Scaling](architecture/scaling-strategies.md), [Monitoring](operations/monitoring.md) |
| **Cost** | [Storage Optimization](architecture/storage-optimization.md) | [Design Decisions](architecture/design-decisions.md) |
| **Troubleshooting** | [Troubleshooting Guide](operations/troubleshooting.md) | [Monitoring](operations/monitoring.md) |

### By Use Case

**Terraform Cloud / CI/CD:**
```
1. Security Overview → Multi-tenant concerns
2. Deployment Patterns → Sidecar pattern
3. Storage Optimization → Cost reduction
4. Load Testing → Capacity validation
```

**Enterprise Multi-Tenant:**
```
1. Security Overview → Critical requirements
2. Isolation Strategies → Technical options
3. Multi-Tenant Deployment → Step-by-step guide
4. Secure Multi-Tenant RFC → Complete architecture
```

**Development / Testing:**
```
1. Getting Started → Basic setup
2. Load Testing → Performance validation
3. Troubleshooting → Problem resolution
```

## 📖 Documentation Types

### Guides (How-to)
Step-by-step instructions for specific tasks:
- [Getting Started](getting-started.md)
- [Multi-Tenant Deployment](security/multi-tenant-deployment.md)
- [Load Testing](operations/load-testing.md)

### Overviews (Conceptual)
Understanding how things work:
- [Security Overview](security/README.md)
- [Design Decisions](architecture/design-decisions.md)
- [Deployment Patterns](operations/deployment-patterns.md)

### Reference (Technical)
Detailed specifications and options:
- [Configuration Reference](reference/configuration.md)
- [API Reference](reference/api.md)
- [Metrics Reference](reference/metrics.md)

### Troubleshooting (Diagnostic)
Problem-solving resources:
- [Troubleshooting Guide](operations/troubleshooting.md)
- [Monitoring](operations/monitoring.md)

## 🔍 Quick Reference

### Common Commands

```bash
# Start load test environment
cd loadtest && make start

# View metrics
curl http://localhost:8080/metrics

# Check logs
kubectl logs deployment/goblet

# Run tests
go test ./...
```

### Important Links

- **Main Repository:** https://github.com/google/goblet
- **Issue Tracker:** https://github.com/google/goblet/issues
- **Security Email:** security@example.com

### Key Concepts

| Term | Definition | Learn More |
|------|------------|------------|
| **Sidecar Pattern** | One Goblet per workload | [Deployment Patterns](operations/deployment-patterns.md#sidecar-pattern) |
| **Tenant Isolation** | Separating cache by user/org | [Isolation Strategies](security/isolation-strategies.md) |
| **Cache Hit Rate** | % of requests served from cache | [Monitoring](operations/monitoring.md) |
| **Tiered Storage** | Hot/cool/archive storage layers | [Storage Optimization](architecture/storage-optimization.md) |

## ✍️ Documentation Standards

### Writing Style

- **Clear:** Simple language, avoid jargon
- **Concise:** Respect reader's time
- **Complete:** Cover common scenarios
- **Current:** Updated with releases

### Code Examples

All examples should:
- Be self-contained
- Include comments
- Show expected output
- Use realistic scenarios

### Cross-References

- Link to related documentation
- Use relative paths
- Keep links up to date
- Verify links in CI

## 🤝 Contributing to Documentation

### Making Changes

1. **Fork** the repository
2. **Create** a branch (`docs/improve-security-guide`)
3. **Edit** documentation (follow style guide)
4. **Test** links and examples
5. **Submit** pull request

### What to Document

**Always document:**
- New features
- Configuration changes
- Breaking changes
- Security implications
- Migration steps

**Consider documenting:**
- Common workflows
- Troubleshooting tips
- Performance tuning
- Integration examples

### Documentation Review

PRs with documentation changes are reviewed for:
- Accuracy
- Completeness
- Clarity
- Consistency with existing docs

## 📊 Documentation Metrics

### Coverage

- Core features: 100%
- Security topics: 100%
- Operations guides: 100%
- API reference: 90%
- Advanced topics: 75%

### Freshness

- Last major update: 2025-11-07
- Review cycle: Quarterly
- Update trigger: Each release

## 🆘 Documentation Support

**Can't find what you need?**

1. Check [index](index.md) for all topics
2. Search GitHub repository
3. Ask in [Discussions](https://github.com/google/goblet/discussions)
4. Open [documentation issue](https://github.com/google/goblet/issues/new?labels=documentation)

**Found an error?**

Please report:
- Incorrect information
- Broken links
- Outdated examples
- Unclear instructions

## 📅 Roadmap

**Coming Soon:**
- Video tutorials
- Interactive examples
- Grafana dashboard templates
- Helm chart documentation
- Terraform module guide

**Under Consideration:**
- Translated documentation
- PDF exports
- Offline documentation
- API playground

---

**Last Updated:** 2025-11-07
**Maintained by:** Goblet Contributors
**License:** Apache 2.0
