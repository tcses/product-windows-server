# Future State - Windows Server Inventory

Planned Windows server infrastructure for Chicago datacenter migration, replacing Elk Grove (EG-*) servers with production (PRD-*) servers.

**Last Updated**: January 2026  
**Environment**: Chicago (PRD-* naming convention)  
**Status**: 🟡 Planned/In Deployment

---

## 📋 Overview

Future state Windows server infrastructure includes:
- **Production CampusVue Servers** - PRD-CNWEB-*, PRD-CVAPI-*, PRD-CNPORT-*
- **Production Web Application Servers** - PRD-WebApps-*
- **Test Servers** - TST-CNWEB-*, TST-WebApps-*

**Naming Convention**: `PRD-{TYPE}-{NUMBER}` (Production) or `TST-{TYPE}-{NUMBER}` (Test)

**Migration Source**: Elk Grove servers (EG-*) - See [current-state.md](current-state.md)

---

## 🎓 Production CampusVue/CampusNexus Servers

### CampusNexus Web Servers

**Purpose**: Host CampusNexus web application (student information system)

| Server Name | Hostname | IP Address | Purpose | Status | Replaces |
|-------------|----------|------------|---------|--------|----------|
| PRD-CNWEB-01 | PRD-CNWEB-01.TCSES.ORG | - | CampusNexus Web #1 | 🟡 Planned | EG-CNWEB-01 |
| PRD-CNWEB-02 | PRD-CNWEB-02.TCSES.ORG | - | CampusNexus Web #2 | 🟡 Planned | EG-CNWEB-02 |
| PRD-CNWEB-03 | PRD-CNWEB-03.TCSES.ORG | - | CampusNexus Web #3 | 🟡 Planned | EG-CNWEB-03 |

**Applications**:
- CampusNexus web application
- Student portal access
- Administrative interfaces

**Load Balancing**: Cloudflare CDN + Cloudflare Tunnel (replaces F5 BIG-IP)

**Architecture**: Internet → Cloudflare → Cloudflare Tunnel (RHEL) → PRD-CNWEB-*

---

### CampusVue API Server

**Purpose**: CampusVue/CampusNexus API services

| Server Name | Hostname | IP Address | Purpose | Status | Replaces |
|-------------|----------|------------|---------|--------|----------|
| PRD-CVAPI-01 | PRD-CVAPI-01.TCSES.ORG | - | CampusVue API Server | 🟡 Planned | EG-CVAPI-01 |

**Applications**:
- CampusVue API endpoints
- Data integration services
- Third-party integrations

**Architecture**: Internet → Cloudflare → Cloudflare Tunnel (RHEL) → PRD-CVAPI-01

---

### CampusNexus Portal Server

**Purpose**: Student and staff portal hosting

| Server Name | Hostname | IP Address | Purpose | Status | Replaces |
|-------------|----------|------------|---------|--------|----------|
| PRD-CNPORT-01 | PRD-CNPORT-01.TCSES.ORG | - | CampusNexus Portal | 🟡 Planned | EG-CNPORT-01 |

**Applications**:
- Student portal
- Staff portal
- Portal-specific services

**Architecture**: Internet → Cloudflare → Cloudflare Tunnel (RHEL) → PRD-CNPORT-01

---

## 🌐 Production Web Application Servers

**Purpose**: Host custom .NET web applications and services

| Server Name | Hostname | IP Address | Purpose | Status | Replaces |
|-------------|----------|------------|---------|--------|----------|
| PRD-WebApps-01 | PRD-WebApps-01.TCSES.ORG | - | Web Applications #1 | 🟡 Planned | EG-WebApps-01, 02 |
| PRD-WebApps-02 | PRD-WebApps-02.TCSES.ORG | - | Web Applications #2 | 🟡 Planned | EG-WebApps-03, 04 |
| PRD-WebApps-03 | PRD-WebApps-03.TCSES.ORG | - | Web Applications #3 | 🟡 Planned | EG-WebApps-05, 06 |
| PRD-WebApps-04 | PRD-WebApps-04.TCSES.ORG | - | Web Applications #4 | 🟡 Planned | EG-WebApps-07, 08 |

**Note**: Consolidation from 8 servers (EG-WebApps-01-08) to 4 servers (PRD-WebApps-01-04)

**Applications Include**:
- FacFinder (faculty directory)
- Custom reporting dashboards
- Student services applications
- Administrative tools
- GitHub Actions runner integrations

**Load Balancing**: Cloudflare CDN + Cloudflare Tunnel (replaces F5 BIG-IP)

**Architecture**: Internet → Cloudflare → Cloudflare Tunnel (RHEL) → PRD-WebApps-*

---

## 🧪 Test Servers

**Purpose**: Test environment for CampusVue and custom applications

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| TST-CNWEB-01 | TST-CNWEB-01.TCSES.ORG | - | CampusNexus Web Test #1 | 🟡 Planned | Test environment |
| TST-WebApps-01 | TST-WebApps-01.TCSES.ORG | - | Web Applications Test #1 | 🟡 Planned | Test environment |

**Additional test servers may be added as needed**

---

## 🏗️ Infrastructure Architecture

### Cloudflare Integration

**Architecture**: Internet → Cloudflare CDN → Cloudflare Tunnel (RHEL) → Windows/IIS Servers

**Components**:
- **Cloudflare CDN**: Global edge locations, DDoS protection, WAF
- **Cloudflare Tunnel**: Encrypted tunnel (cloudflared on RHEL)
  - PRD-CFTunnel-01, 02 (RHEL 10.0 + cloudflared)
  - TST-CFTunnel-01, 02 (RHEL 10.0 + cloudflared)
- **Windows/IIS Servers**: Origin servers (no public IPs required)

**Benefits**:
- ✅ Enhanced security (no public IPs)
- ✅ Zero Trust access
- ✅ Global CDN performance
- ✅ DDoS protection
- ✅ SSL/TLS encryption
- ✅ Cost reduction (eliminate F5 BIG-IP)

### Network

**Datacenter**: Chicago
**Network**: Internal corporate network
**Access**: RDP, IIS Management, PowerShell Remoting, Ansible (WinRM)

**Subnet**: Same subnet as Cloudflare Tunnel servers (PRD-CFTunnel-*)

---

## 🔄 Migration Plan

### Phase 1: Infrastructure Setup
- [ ] Deploy Cloudflare Tunnel servers (PRD-CFTunnel-01, 02)
- [ ] Configure Cloudflare Tunnel endpoints
- [ ] Test connectivity and routing

### Phase 2: Test Environment
- [ ] Deploy test servers (TST-CNWEB-*, TST-WebApps-*)
- [ ] Configure Cloudflare Tunnel for test
- [ ] Validate applications and integrations

### Phase 3: Production Migration
- [ ] Deploy production CampusVue servers (PRD-CNWEB-*, PRD-CVAPI-*, PRD-CNPORT-*)
- [ ] Deploy production web application servers (PRD-WebApps-*)
- [ ] Configure Cloudflare Tunnel for production
- [ ] Migrate applications and data
- [ ] Cutover from EG-* to PRD-* servers

### Phase 4: Decommission
- [ ] Decommission Elk Grove servers (EG-*)
- [ ] Remove F5 BIG-IP load balancer
- [ ] Complete migration documentation

---

## 📊 Summary

| Category | Server Count | Status | Replaces |
|----------|--------------|--------|----------|
| CampusNexus Web | 3 | 🟡 Planned | EG-CNWEB-01, 02, 03 |
| CampusVue API | 1 | 🟡 Planned | EG-CVAPI-01 |
| CampusNexus Portal | 1 | 🟡 Planned | EG-CNPORT-01 |
| Web Applications | 4 | 🟡 Planned | EG-WebApps-01-08 (consolidated) |
| Test Servers | 2+ | 🟡 Planned | New test environment |
| **Total Production** | **9** | **Planned** | **14 EG-* servers** |

**Consolidation**: 14 EG-* servers → 9 PRD-* servers (optimized infrastructure)

---

## 🔗 Related Documentation

- **[Current State Inventory](current-state.md)** - Active Elk Grove servers
- **[Perceptive Content Inventory](perceptive-content.md)** - Perceptive Content servers
- **[src-ansible-win](https://github.com/tcses/src-ansible-win)** - Windows server automation
- **[proj-appdev-planning/knowledge-base/cloudflare-public-apps/](../../../proj-appdev-planning/knowledge-base/cloudflare-public-apps/README.md)** - Cloudflare architecture

---

**Last Updated**: January 2026
