# Windows Server Applications

Complete inventory and documentation of applications hosted on Windows IIS servers.

---

## 📋 Overview

This directory contains comprehensive documentation for all applications hosted on Windows Server infrastructure:

- **[Application Roster](roster.md)** - Complete inventory of all applications
- **[CampusVue/CampusNexus](campusvue/README.md)** - Student Information System documentation
- **[Architecture](architecture.md)** - Overall application architecture and deployment patterns

---

## Application Categories

### Student Information System
- **CampusNexus** - Primary SIS (Anthology)
- **Academic Portal** - Student and staff portals

### Custom .NET Applications
- **Support Desk** - User management and password reset
- **Integration System** - Salesforce sync and integrations
- **Custom Student/Staff Portals** - School-specific portals
- **Cashiering Site** - Payment processing
- **Cashiering Site API** - Backend API service

### Deprecated Applications (Historic)
- **Prospective Student Application Portals** - Deprecated in 2025, decommissioned (see [roster.md](roster.md#-deprecated-applications-historic-reference))

### Integration Services
- **Integration Engine** - Scheduled task execution
- **Custom Windows Services** - Background processing

---

## Quick Reference

| Category | Applications | Servers | Status |
|----------|--------------|---------|--------|
| CampusNexus | Web Client, API, Portal | EG-CNWEB-*, EG-CVAPI-*, EG-CNPORT-* | 🟢 Active |
| Custom Apps | Multiple .NET apps | EG-WebApps-01-08 | 🟢 Active |
| Integration | Services, Scheduled Tasks | EG-Integrate-01 | 🟢 Active |

---

**Last Updated**: January 2026
