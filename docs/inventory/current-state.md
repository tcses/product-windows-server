# Current State - Windows Server Inventory

Complete inventory of active production and test Windows servers in the Elk Grove datacenter.

**Last Updated**: January 2026  
**Environment**: Elk Grove (EG-* naming convention)  
**Status**: Active Production/Test

---

## 📋 Overview

Current Windows server infrastructure includes:
- **CampusVue/CampusNexus** - Student Information System (SIS)
- **Custom Web Applications** - Custom .NET applications
- **Perceptive Content** - Document management system

**Naming Convention**: `EG-{TYPE}-{NUMBER}` (Elk Grove prefix)

---

## 🎓 CampusVue/CampusNexus Servers

### CampusNexus Web Servers

**Purpose**: Host CampusNexus web application (student information system)

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| EG-CNWEB-01 | EG-CNWEB-01.TCSES.ORG | - | CampusNexus Web #1 | 🟢 Active | Production web server |
| EG-CNWEB-02 | EG-CNWEB-02.TCSES.ORG | - | CampusNexus Web #2 | 🟢 Active | Production web server (load balanced) |
| EG-CNWEB-03 | EG-CNWEB-03.TCSES.ORG | - | CampusNexus Web #3 | 🟢 Active | Production web server (load balanced) |

**Applications**:
- CampusNexus web application
- Student portal access
- Administrative interfaces

**Load Balancing**: F5 BIG-IP load balancer (legacy)

**Migration Target**: PRD-CNWEB-01, 02, 03 (Chicago datacenter)

---

### CampusVue API Server

**Purpose**: CampusVue/CampusNexus API services

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| EG-CVAPI-01 | EG-CVAPI-01.TCSES.ORG | - | CampusVue API Server | 🟢 Active | Production API server |

**Applications**:
- CampusVue API endpoints
- Data integration services
- Third-party integrations

**Migration Target**: PRD-CVAPI-01 (Chicago datacenter)

---

### CampusNexus Portal Server

**Purpose**: Student and staff portal hosting

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| EG-CNPORT-01 | EG-CNPORT-01.TCSES.ORG | - | CampusNexus Portal | 🟢 Active | Production portal server |

**Applications**:
- Student portal
- Staff portal
- Portal-specific services

**Migration Target**: PRD-CNPORT-01 (Chicago datacenter)

---

## 🌐 Custom Web Application Servers

**Purpose**: Host custom .NET web applications and services

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| EG-WebApps-01 | EG-WebApps-01.TCSES.ORG | - | Web Applications #1 | 🟢 Active | Custom .NET apps |
| EG-WebApps-02 | EG-WebApps-02.TCSES.ORG | - | Web Applications #2 | 🟢 Active | Custom .NET apps |
| EG-WebApps-03 | EG-WebApps-03.TCSES.ORG | - | Web Applications #3 | 🟢 Active | Custom .NET apps |
| EG-WebApps-04 | EG-WebApps-04.TCSES.ORG | - | Web Applications #4 | 🟢 Active | Custom .NET apps |
| EG-WebApps-05 | EG-WebApps-05.TCSES.ORG | - | Web Applications #5 | 🟢 Active | Custom .NET apps |
| EG-WebApps-06 | EG-WebApps-06.TCSES.ORG | - | Web Applications #6 | 🟢 Active | Custom .NET apps |
| EG-WebApps-07 | EG-WebApps-07.TCSES.ORG | - | Web Applications #7 | 🟢 Active | Custom .NET apps |
| EG-WebApps-08 | EG-WebApps-08.TCSES.ORG | - | Web Applications #8 | 🟢 Active | Custom .NET apps |

**Applications Include**:
- FacFinder (faculty directory)
- Custom reporting dashboards
- Student services applications
- Administrative tools
- GitHub Actions runner integrations

**Load Balancing**: F5 BIG-IP load balancer (legacy)

**Migration Target**: PRD-WebApps-01, 02, 03, 04 (Chicago datacenter - consolidated)

---

## 📄 Perceptive Content Servers

**Purpose**: Perceptive Content (ImageNow) document management system

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| EG-INOWWEB | EG-INOWWEB.TCSES.ORG | - | Perceptive Content Web | 🟢 Active | WebNow/Perceptive Content web server |

**Applications**:
- Perceptive Content web interface (WebNow)
- Document management services
- Integration endpoints

**URL**: `webnow.tcsedsystem.edu`

**Reverse Proxy**: NGINX (PRD-NGINX-Perceptive planned)

**See Also**: [perceptive-content.md](perceptive-content.md) for detailed documentation

---

## 🏗️ Infrastructure

### Load Balancing

**Current**: F5 BIG-IP hardware load balancer
- Single point of failure
- Limited DDoS protection
- Expensive licensing and maintenance

**Target**: Cloudflare CDN + Cloudflare Tunnel (see future-state.md)

### Network

**Datacenter**: Elk Grove
**Network**: Internal corporate network
**Access**: RDP, IIS Management, PowerShell Remoting

---

## 🔄 Migration Status

**Elk Grove → Chicago Migration**:
- **Status**: 🟡 In Planning/Deployment Phase
- **Timeline**: TBD
- **Target Servers**: See [future-state.md](future-state.md)

**Migration Benefits**:
- Modern cloud-native architecture (Cloudflare)
- Enhanced security (no public IPs)
- Improved performance (CDN)
- Cost reduction (eliminate F5 BIG-IP)

---

## 📊 Summary

| Category | Server Count | Status |
|----------|--------------|--------|
| CampusNexus Web | 3 | 🟢 Active |
| CampusVue API | 1 | 🟢 Active |
| CampusNexus Portal | 1 | 🟢 Active |
| Web Applications | 8 | 🟢 Active |
| Perceptive Content | 1 | 🟢 Active |
| **Total** | **14** | **Active** |

---

**Last Updated**: January 2026
