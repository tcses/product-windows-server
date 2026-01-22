# CampusVue/CampusNexus Documentation

Complete documentation for CampusVue (CampusNexus) Student Information System infrastructure.

**Last Updated**: January 2026  
**Source**: `proj-appdev-planning/knowledge-base/campusnexus/`

---

## 📋 Overview

CampusNexus (Anthology Student Information System) is the primary SIS used across all school domains. This documentation covers:

- **URLs and Environments** - Production, test, and training URLs
- **Architecture** - Server infrastructure and load balancing
- **Components** - Web client, API, and portal servers
- **Configuration** - IIS settings and post-install configuration

---

## 🏗️ Architecture

### Production Architecture

```
Internet
   ↓
☁️ Cloudflare (CDN + WAF + DDoS + SSL)
   ↓
🔒 Cloudflare Load Balancer (current)
   ↓ (Planned: Cloudflare Tunnel)
🐧 PRD-CFTunnel-01, 02 (RHEL) - Planned
   ↓
🖥️ PRD-CNWEB-01, 02, 03 (Windows/IIS) - Planned
🖥️ PRD-CVAPI-01 (Windows/IIS) - Planned
🖥️ PRD-CNPORT-01 (Windows/IIS) - Planned
   ↓
Backend Services (SQL Cluster, API)
```

**Current State**: EG-CNWEB-01, 02, 03 (Elk Grove)  
**Target State**: PRD-CNWEB-01, 02, 03 (Chicago)

---

## 🌐 URLs and Environments

### Production URLs

**Load Balancer**: `campusnexus.tcsedsystem.edu`  
**School-Specific URLs**:
- `campusnexus.thechicagoschool.edu`
- `campusnexus.pacificoaks.edu`
- `campusnexus.saybrook.edu`
- `campusnexus.collegesoflaw.edu`
- `campusnexus.kansashsc.org`

**Status**: ✅ Operational  
**Backend**: EG-CNWEB-01, 02, 03 (current) → PRD-CNWEB-01, 02, 03 (planned)

### Test Environment

**Current Workaround**: `newtestnexus.tcsedsystem.edu`
- Direct LAN DNS to single test server
- No load balancing
- No Cloudflare protection
- Status: ✅ Operational (workaround)

**Original URL** (Offline): `testnexus-lb.tcsedsystem.edu`
- Cloudflare Load Balancer
- Status: ❌ Offline (since upgrade)

**Planned**: Migrate to Cloudflare Tunnel architecture

### Training Environment

**URL**: `trainnexus-lb.tcsedsystem.edu`  
**Status**: ✅ Operational  
**Backend**: Training origin pool

---

## 🖥️ Server Components

### CampusNexus Web Servers

**Purpose**: Host CampusNexus web application (student information system)

**Production**:
- **Current**: EG-CNWEB-01, 02, 03 (Windows/IIS)
- **Planned**: PRD-CNWEB-01, 02, 03 (Windows/IIS)

**Test**:
- **Planned**: TST-CNWEB-* (Windows/IIS)

**Applications**:
- CampusNexus web application
- Student portal access
- Administrative interfaces

---

### CampusNexus API Server

**Purpose**: CampusNexus API services

**Production**:
- **Current**: EG-CVAPI-01 (Windows/IIS)
- **Planned**: PRD-CVAPI-01 (Windows/IIS)

**Applications**:
- CampusNexus API endpoints
- Data integration services
- Third-party integrations

---

### Academic Portal Server

**Purpose**: Student and staff portal hosting

**Production**:
- **Current**: EG-CNPORT-01 (Windows/IIS)
- **Planned**: PRD-CNPORT-01 (Windows/IIS)

**Applications**:
- Student portal
- Staff portal
- Portal-specific services

---

## ⚙️ Configuration

### IIS Configuration

**Post-Install Configuration**: See `src-ansible-win/roles/campusnexus/`

**Features**:
- Extended W3C logging with Cloudflare headers
- Custom log fields (CF-Connecting-IP, CF-RAY, etc.)
- IIS settings optimization
- Hosts file configuration (environment-specific)

### Load Balancing

**Current**: Cloudflare Load Balancer  
**Planned**: Cloudflare Tunnel (RHEL) → Windows/IIS

**Benefits**:
- Enhanced security (no public IPs)
- Unified architecture
- Better performance (CDN)
- Cost reduction (eliminate F5)

---

## 🔄 Migration Plan

### Elk Grove → Chicago Migration

**Status**: 🟡 In Planning/Deployment Phase

**Servers**:
- EG-CNWEB-01, 02, 03 → PRD-CNWEB-01, 02, 03
- EG-CVAPI-01 → PRD-CVAPI-01
- EG-CNPORT-01 → PRD-CNPORT-01

**Architecture**:
- Current: Cloudflare Load Balancer → EG-* servers
- Target: Cloudflare Tunnel (RHEL) → PRD-* servers

See [Future State Inventory](../inventory/future-state.md) for detailed migration planning.

---

## 📚 Related Documentation

- **[URLs and Environments](URLS.md)** - Complete URL inventory
- **[Application Roster](../roster.md)** - Complete application inventory
- **[Architecture](../architecture.md)** - Overall architecture documentation
- **[Inventory - Current State](../inventory/current-state.md)** - Current server inventory
- **[Inventory - Future State](../inventory/future-state.md)** - Planned server inventory
- **[src-ansible-win/campusnexus](../../../src-ansible-win/docs/campusnexus/README.md)** - Ansible automation

---

**Last Updated**: January 2026
