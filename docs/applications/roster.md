# Application Roster

Complete inventory of all applications hosted on Windows IIS servers.

**Last Updated**: January 2026  
**Source**: `proj-appdev-planning/knowledge-base/inventory/SensitiveApplications.md`

---

## 📋 Overview

This document provides a comprehensive roster of all applications hosted on Windows Server infrastructure, including production, test, and training environments.

---

## 🎓 CampusNexus (Student Information System)

### CampusNexus Web Client

**Product**: Anthology CampusNexus Student (CampusVue Web Portal)  
**Environment**: Production, Test, Training  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET  
**Data Security**: PII, PCI Storage

**Production URLs**:
- `campusnexus.tcsedsystem.edu` (load balancer)
- `campusnexus.thechicagoschool.edu`
- `campusnexus.pacificoaks.edu`
- `campusnexus.saybrook.edu`
- `campusnexus.collegesoflaw.edu`
- `campusnexus.kansashsc.org`

**Test URLs**:
- `newtestnexus.tcsedsystem.edu` (workaround - direct DNS)
- `testnexus-lb.tcsedsystem.edu` (offline - load balancer)

**Training URLs**:
- `trainnexus-lb.tcsedsystem.edu` (load balancer)

**Backend Servers**:
- **Production**: PRD-CNWEB-01, 02, 03 (Windows/IIS) - Planned
- **Current**: EG-CNWEB-01, 02, 03 (Windows/IIS) - Active
- **Test**: TST-CNWEB-* (Windows/IIS) - Planned
- **Training**: Training origin pool

**Components**:
- **Web Client**: CampusNexus Portal
- **OAuth Login Portal**: CampusNexus STS (Security Token Service)

**Infrastructure**:
- Load Balancer: Cloudflare (production, training)
- SSL, CDN, WAF: Cloudflare
- Hosting Ingress: Cloudflare Tunnel (planned) / Cloudflare Load Balancer (current)
- Backend: Adjacent MSSQL Cluster, Adjacent API Server
- Monitoring: Azure Arc, LogicMonitor, Datadog
- Antivirus: Windows Defender
- Hosting: VMware VM

---

### CampusNexus API

**Product**: CampusNexus API Services  
**Environment**: Production  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET

**Backend Servers**:
- **Production**: PRD-CVAPI-01 (Windows/IIS) - Planned
- **Current**: EG-CVAPI-01 (Windows/IIS) - Active

**Function**: API endpoints for CampusNexus data access and integrations

---

### Academic Portal

**Product**: CampusNexus Portal  
**Environment**: Production  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET

**Production URLs**:
- `portal.thechicagoschool.edu`
- `portal.pacificoaks.edu`
- `portal.saybrook.edu`
- `portal.collegesoflaw.edu`
- `portal.kansashsc.org`

**Backend Servers**:
- **Production**: PRD-CNPORT-01 (Windows/IIS) - Planned
- **Current**: EG-CNPORT-01 (Windows/IIS) - Active

**Function**: Student and staff portal hosting

---

## 🔧 Custom .NET Web Applications

### Support Desk User Management

**Product**: Support Desk Portal  
**Environment**: Production  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET  
**Tenancy**: Single Tenant  
**Data Security**: PII Storage

**URL**: `https://apps.tcsedsystem.edu`

**Backend Servers**: EG-WebApps-* (Windows/IIS)

**Function**: User management, group membership, onboarding automation, password reset

**Infrastructure**:
- Load Balancer: f5 (current) / Cloudflare Tunnel (planned)
- SSL, CDN, WAF: Cloudflare
- Backend: Adjacent SQL Cluster
- Monitoring: Azure Arc, LogicMonitor, Datadog

---

### Integration System

**Product**: Integration Engine  
**Environment**: Production  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET  
**Tenancy**: Single Tenant  
**Data Security**: PII Egress, Storage

**URL**: `https://integration.tcsedsystem.edu`

**Backend Servers**: EG-Integrate-01 (Windows/IIS)

**Function**: Listener for Salesforce.com backend student lead PII data sync, custom Windows services, scheduled tasks

**Infrastructure**:
- Load Balancer: f5 (current) / Cloudflare Tunnel (planned)
- SSL, CDN, WAF: Cloudflare
- Backend: Adjacent SQL Cluster
- Monitoring: Azure Arc, LogicMonitor, Datadog
- Logs: E: drive application logs

**Migration**: PRD-Integrate-01 via backup restore (EG-Integrate-01 is new, only 6 months old)

---

### Custom Student/Staff Portals

**Product**: School-Specific Portals  
**Environment**: Production  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET  
**Tenancy**: Multi-Tenant  
**Data Security**: Egress for PCI, Store for PII

**URLs**:
- `https://apps.pacificoaks.edu`
- `https://apps.thechicagoschool.edu`
- `https://apps.kansashsc.edu`
- `https://apps.uws.edu`
- `https://apps.collegesoflaw.edu`
- `https://apps.saybrook.edu`

**Backend Servers**: EG-WebApps-* (Windows/IIS)

**Function**: Class registration, attendance, tuition payments, grade posting

**Infrastructure**:
- Load Balancer: f5 (current) / Cloudflare Tunnel (planned)
- SSL, CDN, WAF: Cloudflare
- Backend: Adjacent SQL Server Cluster
- Monitoring: Azure Arc, LogicMonitor, Datadog

---

### Prospective Student Application Portals

**Product**: Application Processing Portals  
**Environment**: Production  
**Hosting**: Windows IIS  
**Code**: Microsoft .NET  
**Tenancy**: Multi-Tenant  
**Data Security**: Egress for PCI, Store for PII

**URLs**:
- `https://apply.pacificoaks.edu`
- `https://apply.saybrook.edu`
- `https://apply.kansashsc.edu`
- `https://apply.uws.edu`
- `https://apply.collegesoflaw.edu`
- `https://apply.thechicagoschool.edu`

**Backend Servers**: EG-WebApps-* (Windows/IIS)

**Function**: Prospective student application processing

**Infrastructure**:
- Load Balancer: f5 (current) / Cloudflare Tunnel (planned)
- SSL, CDN, WAF: Cloudflare
- Backend: Adjacent SQL Server Cluster
- Monitoring: Azure Arc, LogicMonitor, Datadog

---

### Cashiering Site

**Product**: Cashiering Portal  
**Environment**: Production  
**Hosting**: AWS EC2 (Windows IIS)  
**Code**: Microsoft .NET  
**Tenancy**: Multi-Tenant  
**Data Security**: Egress PII, PCI

**URL**: `https://cashier.tcsedsystem.edu`

**Infrastructure**:
- Load Balancer: AWS EC2 Application Load Balancer / Elastic Beanstalk Autoscaling
- SSL: AWS Certificate Manager
- CDN: None
- WAF: AWS VPC Firewall
- Backend: AWS DynamoDB, AWS Queue Service, AWS Lambda Functions, AWS Secrets Manager
- Monitoring: AWS CloudWatch, Datadog

**Function**: Staff-facing application for Student Accounts and Admissions teams to accept phone payments and process credit card payments

**Note**: Hosted on AWS EC2, not on-premises Windows servers

---

### Cashiering Site API Backend

**Product**: Cashiering API Service  
**Environment**: Production  
**Hosting**: Windows IIS (On-Premises)  
**Code**: Microsoft .NET  
**Tenancy**: Multi-Tenant  
**Data Security**: Egress for PII

**URL**: `https://service.tcsedsystem.edu`

**Backend Servers**: EG-WebApps-* (Windows/IIS)

**Function**: Backend service supporting primary Cashier web applications hosted in AWS, for read access to primary SIS SQL Data

**Infrastructure**:
- Load Balancer: f5 (current) / Cloudflare Tunnel (planned)
- SSL, CDN, WAF: Cloudflare
- Backend: Adjacent SQL Server Cluster
- Backend Security: Network Allowlist Access Only, Rotating Host Key Access Security
- Monitoring: Azure Arc, LogicMonitor, Datadog

---

## 📊 Application Summary

| Application | Environment | Servers | Status | Notes |
|-------------|-------------|---------|--------|-------|
| CampusNexus Web | Production | EG-CNWEB-01, 02, 03 | 🟢 Active | Migrating to PRD-CNWEB-* |
| CampusNexus Web | Test | TST-CNWEB-* | 🟡 Planned | Workaround: newtestnexus.tcsedsystem.edu |
| CampusNexus Web | Training | Training pool | 🟢 Active | trainnexus-lb.tcsedsystem.edu |
| CampusNexus API | Production | EG-CVAPI-01 | 🟢 Active | Migrating to PRD-CVAPI-01 |
| Academic Portal | Production | EG-CNPORT-01 | 🟢 Active | Migrating to PRD-CNPORT-01 |
| Support Desk | Production | EG-WebApps-* | 🟢 Active | apps.tcsedsystem.edu |
| Integration System | Production | EG-Integrate-01 | 🟢 Active | integration.tcsedsystem.edu |
| Custom Portals | Production | EG-WebApps-* | 🟢 Active | apps.{school}.edu |
| Application Portals | Production | EG-WebApps-* | 🟢 Active | apply.{school}.edu |
| Cashiering Site | Production | AWS EC2 | 🟢 Active | cashier.tcsedsystem.edu (AWS) |
| Cashiering API | Production | EG-WebApps-* | 🟢 Active | service.tcsedsystem.edu |

---

## 🔄 Migration Status

**Elk Grove → Chicago Migration**:
- **Status**: 🟡 In Planning/Deployment Phase
- **Target Servers**: PRD-CNWEB-*, PRD-CVAPI-*, PRD-CNPORT-*, PRD-WebApps-*
- **Architecture**: Cloudflare Tunnel (RHEL) → Windows/IIS

See [Architecture](architecture.md) for detailed migration plans.

---

## 📚 Related Documentation

- **[CampusVue/CampusNexus](campusvue/README.md)** - Detailed CampusNexus documentation
- **[Architecture](architecture.md)** - Application architecture and deployment patterns
- **[Inventory - Current State](../inventory/current-state.md)** - Current server inventory
- **[Inventory - Future State](../inventory/future-state.md)** - Planned server inventory

---

**Last Updated**: January 2026  
**Source**: `proj-appdev-planning/knowledge-base/inventory/SensitiveApplications.md`
