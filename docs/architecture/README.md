# Windows Server Architecture

Complete architecture documentation for Windows Server infrastructure, including application deployment patterns, load balancing, and migration plans.

**Last Updated**: January 2026

---

## 📋 Overview

This directory contains comprehensive architecture documentation:

- **[Architecture Overview](architecture.md)** - Overall system architecture
- **[Migration Planning](migration.md)** - Elk Grove → Chicago migration
- **[Deployment Patterns](deployment-patterns.md)** - Application deployment patterns

---

## 🏗️ Architecture Layers

### Layer 1: Cloudflare (CDN/WAF/DDoS)

**Function**: Global CDN, DDoS protection, WAF, SSL/TLS encryption

**Components**:
- Cloudflare CDN (edge locations worldwide)
- Web Application Firewall (WAF)
- DDoS mitigation
- SSL/TLS encryption

### Layer 2: Cloudflare Tunnel (RHEL)

**Function**: Encrypted tunnel proxy (replaces F5 BIG-IP)

**Components**:
- **Production**: PRD-CFTunnel-01, 02 (RHEL 10.0 + cloudflared)
- **Test**: TST-CFTunnel-01, 02 (RHEL 10.0 + cloudflared)

**Benefits**:
- No public IPs required
- Encrypted connection
- High availability (2 servers)

### Layer 3: Windows/IIS Origin Servers

**Function**: Host .NET web applications

**Server Categories**:
- **CampusNexus**: PRD-CNWEB-*, PRD-CVAPI-*, PRD-CNPORT-*
- **Custom Apps**: PRD-WebApps-*
- **Integration**: PRD-Integrate-* (planned)

---

## 🔄 Migration Architecture

### Current State (Elk Grove)

```
Internet
   ↓
F5 BIG-IP Load Balancer
   ↓
EG-CNWEB-01, 02, 03 (Windows/IIS)
EG-CVAPI-01 (Windows/IIS)
EG-CNPORT-01 (Windows/IIS)
EG-WebApps-01-08 (Windows/IIS)
```

### Target State (Chicago)

```
Internet
   ↓
☁️ Cloudflare (CDN + WAF + DDoS + SSL)
   ↓
🔒 Cloudflare Tunnel
   ↓
🐧 PRD-CFTunnel-01, 02 (RHEL)
   ↓
🖥️ PRD-CNWEB-01, 02, 03 (Windows/IIS)
🖥️ PRD-CVAPI-01 (Windows/IIS)
🖥️ PRD-CNPORT-01 (Windows/IIS)
🖥️ PRD-WebApps-01, 02, 03, 04 (Windows/IIS)
```

---

## 📚 Related Documentation

- **[Application Roster](../applications/roster.md)** - Complete application inventory
- **[CampusVue/CampusNexus](../applications/campusvue/README.md)** - CampusNexus documentation
- **[Inventory - Current State](../inventory/current-state.md)** - Current server inventory
- **[Inventory - Future State](../inventory/future-state.md)** - Planned server inventory

---

**Last Updated**: January 2026
