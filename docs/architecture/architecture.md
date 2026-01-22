# Windows Server Architecture

Complete architecture documentation for Windows Server infrastructure, application deployment patterns, and system design.

**Last Updated**: January 2026  
**Source**: `proj-appdev-planning/app-dev-planning/web-services-migration/`

---

## 📋 Overview

Windows Server infrastructure hosts multiple categories of applications:

1. **CampusNexus (Anthology SIS)** - Student Information System
2. **Custom .NET Web Applications** - Custom developed applications
3. **Integration Services** - Background services and scheduled tasks

---

## 🏗️ Architecture Layers

### Layer 1: Cloudflare (Global CDN/WAF/DDoS)

**Function**: Global content delivery, security, and performance

**Components**:
- **CDN**: Edge locations worldwide for static content caching
- **DDoS Protection**: Automatic mitigation of distributed attacks
- **Web Application Firewall (WAF)**: Application-layer security
- **SSL/TLS Encryption**: End-to-end encryption
- **Rate Limiting**: API endpoint protection

**Benefits**:
- Global performance (edge caching)
- Enhanced security (WAF, DDoS protection)
- Cost reduction (eliminate F5 BIG-IP)
- Automatic SSL certificate management

---

### Layer 2: Cloudflare Tunnel (RHEL Proxy Layer)

**Function**: Encrypted tunnel proxy (replaces F5 BIG-IP and Windows-local proxies)

**Components**:
- **Production**: PRD-CFTunnel-01, 02 (RHEL 10.0 + cloudflared daemon)
- **Test**: TST-CFTunnel-01, 02 (RHEL 10.0 + cloudflared daemon)

**Function**:
- Centralized proxy for ALL public-facing IIS applications
- Encrypted tunnel (no public IPs required)
- High availability (2 servers for redundancy)
- Localhost file pointers to origin servers

**Scope**: Serves BOTH custom apps AND CampusNexus cluster

**Benefits**:
- No public IPs on origin servers
- Encrypted connection from Cloudflare
- Unified proxy architecture
- Eliminates Windows-local proxy services

---

### Layer 3: Windows/IIS Origin Servers

**Function**: Host .NET web applications and services

#### CampusNexus Cluster

**Production Servers**:
- **PRD-CNWEB-01, 02, 03** - Web servers (Windows/IIS)
- **PRD-CVAPI-01** - API server (Windows/IIS)
- **PRD-CNPORT-01** - Portal server (Windows/IIS)

**Current Servers**:
- **EG-CNWEB-01, 02, 03** - Web servers (Windows/IIS)
- **EG-CVAPI-01** - API server (Windows/IIS)
- **EG-CNPORT-01** - Portal server (Windows/IIS)

**Applications**:
- CampusNexus web application
- CampusNexus API services
- Academic Portal

#### Custom Application Servers

**Production Servers** (Planned):
- **PRD-WebApps-01, 02, 03, 04** - Custom .NET applications (Windows/IIS)

**Current Servers**:
- **EG-WebApps-01-08** - Custom .NET applications (Windows/IIS)

**Applications Include**:
- Support Desk (apps.tcsedsystem.edu)
- Integration System (integration.tcsedsystem.edu)
- Custom Student/Staff Portals (apps.{school}.edu)
- Prospective Student Application Portals (apply.{school}.edu)
- Cashiering Site API (service.tcsedsystem.edu)

#### Integration Servers

**Production Servers**:
- **EG-Integrate-01** - Integration services (Windows/IIS)

**Applications**:
- Custom Windows services
- Scheduled tasks
- Background processing

---

## 🔄 Complete Traffic Flow

### Production Architecture (Target State)

```
Internet Users
   ↓
☁️ Cloudflare Global CDN
   ├─ DDoS Protection
   ├─ Web Application Firewall (WAF)
   ├─ SSL/TLS Encryption
   └─ CDN Caching
   ↓
🔒 Cloudflare Tunnel (Encrypted)
   ↓
🐧 PRD-CFTunnel-01, 02 (RHEL 10.0)
   ├─ cloudflared daemon
   ├─ Localhost file pointers for ALL public-facing apps
   ├─ High availability (2 servers)
   └─ Unified proxy for ALL IIS hosting
   ↓
   ├─────────────────────┬─────────────────────┬─────────────────────┐
   ↓                     ↓                     ↓                     ↓
🖥️ CampusNexus        🖥️ Academic Portal   🖥️ Custom Apps       🖥️ Integration
PRD-CNWEB-01-03       PRD-CNPORT-01        PRD-WebApps-01-04   PRD-Integrate-*
PRD-CVAPI-01
   
All Windows/IIS Servers:
   ├─ .NET Framework applications
   ├─ IIS application pools
   ├─ Service accounts
   └─ GitHub Actions runners
   ↓
Backend Services
   ├─ SQL Server Cluster
   ├─ API services
   └─ Integration endpoints
```

---

## 📊 Server Consolidation

### Before (Elk Grove)

**Custom Application Servers**: 8 servers (EG-WebApps-01-08)  
**CampusNexus Cluster**: 5 servers (EG-CNWEB-01-03, EG-CVAPI-01, EG-CNPORT-01)  
**Load Balancer**: F5 BIG-IP hardware  
**Windows-Local Proxies**: On each CampusNexus server  
**Total**: 13 Windows servers + F5 hardware

### After (Chicago PRD)

**Custom Application Servers**: 4 servers (PRD-WebApps-01-04) - **50% reduction**  
**CampusNexus Cluster**: 5 servers (PRD-CNWEB-01-03, PRD-CVAPI-01, PRD-CNPORT-01)  
**Unified Proxy**: 2 RHEL servers (PRD-CFTunnel-01, 02)  
**Load Balancer**: ✅ Eliminated (replaced by Cloudflare)  
**Windows-Local Proxies**: ✅ Eliminated (replaced by centralized tunnel)  
**Total**: 9 Windows servers + 2 RHEL tunnel servers

**Consolidation**: 13 → 9 Windows servers (**31% reduction**)

---

## 🔐 Security Architecture

### Network Security

**No Public IPs**: Origin servers have no public IP addresses  
**Encrypted Tunnel**: All traffic through Cloudflare Tunnel  
**Zero Trust**: Cloudflare manages authentication  
**Network Isolation**: Origin servers on private subnet

### Application Security

**WAF**: Web Application Firewall at Cloudflare edge  
**DDoS Protection**: Automatic mitigation  
**SSL/TLS**: End-to-end encryption  
**Rate Limiting**: API endpoint protection

### Server Security

**Windows Defender**: Antivirus  
**Windows Updates**: Automated patching  
**Service Accounts**: Least privilege  
**Datadog**: Security monitoring

---

## 📈 Performance Architecture

### CDN Caching

**Static Assets**: Cached at Cloudflare edge  
**Dynamic Content**: Passed through to origin  
**Cache Rules**: Per-application configuration

### Load Distribution

**Cloudflare**: Distributes traffic globally  
**Tunnel Servers**: High availability (2 servers)  
**Origin Servers**: Load balanced via Cloudflare

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

**Limitations**:
- Hardware load balancer (single point of failure)
- Limited DDoS protection
- No CDN capabilities
- Expensive licensing and maintenance
- Manual SSL certificate management

### Target State (Chicago PRD)

```
Internet
   ↓
☁️ Cloudflare (Global CDN + DDoS + WAF + SSL)
   ↓
🔒 Cloudflare Tunnel (Encrypted Tunnel)
   ↓
🐧 PRD-CFTunnel-01, 02 (RHEL 10.0 + cloudflared)
   ↓
🖥️ PRD-CNWEB-01, 02, 03 (Windows/IIS)
🖥️ PRD-CVAPI-01 (Windows/IIS)
🖥️ PRD-CNPORT-01 (Windows/IIS)
🖥️ PRD-WebApps-01, 02, 03, 04 (Windows/IIS)
```

**Benefits**:
- ✅ Cloud-native architecture
- ✅ Enhanced security (no public IPs)
- ✅ Global CDN performance
- ✅ Cost reduction (eliminate F5)
- ✅ Unified proxy architecture

---

## 📚 Related Documentation

- **[Application Roster](../applications/roster.md)** - Complete application inventory
- **[CampusVue/CampusNexus](../applications/campusvue/README.md)** - CampusNexus documentation
- **[Migration Planning](migration.md)** - Detailed migration plans
- **[Inventory - Current State](../inventory/current-state.md)** - Current server inventory
- **[Inventory - Future State](../inventory/future-state.md)** - Planned server inventory

---

**Last Updated**: January 2026
