# Windows Server - Documentation and Inventory

![Windows](https://img.shields.io/badge/Windows-Server-0078D6?logo=windows)
![IIS](https://img.shields.io/badge/IIS-Web_Servers-0078D4)
![CampusNexus](https://img.shields.io/badge/CampusNexus-SIS-00A1E0)

Comprehensive documentation and inventory for Windows Server infrastructure, including IIS web servers, CampusVue (CampusNexus) servers, custom applications, and Perceptive Content servers.

---

## 📋 Repository Purpose

This repository houses all documentation and inventory for:

- **Windows IIS Web Servers** - Production and test web application hosting
- **CampusVue/CampusNexus Servers** - Student Information System (SIS) infrastructure
- **Custom Application Servers** - Custom .NET web applications and services
- **Perceptive Content Servers** - Document management system infrastructure
- **Integration Servers** - Windows services and scheduled tasks

**Automation**: For active Ansible automation and deployment, see:
- **[src-ansible-win](https://github.com/tcses/src-ansible-win)** - Active Windows server automation

---

## 🏗️ Repository Structure

```
product-windows-server/
├── README.md                    # This file - repository overview
├── docs/                        # 📚 Comprehensive documentation
│   ├── inventory/               # Server inventory documentation
│   │   ├── README.md            # Inventory overview and index
│   │   ├── current-state.md     # Current production/test servers
│   │   ├── future-state.md      # Planned migration servers
│   │   └── perceptive-content.md # Perceptive Content server inventory
│   ├── architecture/            # Architecture and design documents
│   ├── iis/                     # IIS configuration and management
│   ├── campusvue/               # CampusVue/CampusNexus documentation
│   └── applications/            # Custom application documentation
└── .gitignore                   # Git ignore patterns
```

---

## 🚀 Quick Start

### Server Inventory

- **[Current State Inventory](docs/inventory/current-state.md)** - Active production and test servers
- **[Future State Inventory](docs/inventory/future-state.md)** - Planned migration servers (Elk Grove → Chicago)
- **[Perceptive Content Inventory](docs/inventory/perceptive-content.md)** - Perceptive Content server details

### Automation

For Windows server automation and deployment:
- **[src-ansible-win](https://github.com/tcses/src-ansible-win)** - Ansible playbooks for Windows server management

---

## 📚 Documentation Index

### Inventory

- **[Inventory Overview](docs/inventory/README.md)** - Complete inventory index
- **[Current State](docs/inventory/current-state.md)** - Active servers (EG-* naming)
- **[Future State](docs/inventory/future-state.md)** - Planned servers (PRD-* naming)
- **[Perceptive Content](docs/inventory/perceptive-content.md)** - Perceptive Content servers

### Applications

- **[Application Overview](docs/applications/README.md)** - Application documentation index
- **[Application Roster](docs/applications/roster.md)** - Complete application inventory
- **[CampusVue/CampusNexus](docs/applications/campusvue/README.md)** - Student Information System documentation
- **[CampusNexus URLs](docs/applications/campusvue/URLS.md)** - URL inventory and environments

### Architecture

- **[Architecture Overview](docs/architecture/README.md)** - Overall Windows server architecture
- **[System Architecture](docs/architecture/architecture.md)** - Complete architecture documentation
- **[Migration Planning](docs/architecture/migration.md)** - Elk Grove → Chicago migration

---

## 🔗 Related Repositories

### Infrastructure Documentation
- **[product-github](https://github.com/tcses/product-github)** - GitHub standards, workflows, and CI/CD patterns
- **[product-rhel-servers](https://github.com/tcses/product-rhel-servers)** - RHEL server documentation
- **[product-cloudflare](https://github.com/tcses/product-cloudflare)** - Cloudflare infrastructure management
- **[proj-appdev-planning](https://github.com/tcses/proj-appdev-planning)** - Application development planning and knowledge base

### Automation
- **[src-ansible-win](https://github.com/tcses/src-ansible-win)** - Active Windows server automation
- **[src-ansible-rhel](https://github.com/tcses/src-ansible-rhel)** - RHEL server automation

---

## 📝 Maintenance

### Regular Tasks

1. **Update Server Inventory**: After new server deployments
2. **Update Migration Status**: Track Elk Grove → Chicago migration progress
3. **Document Architecture Changes**: When infrastructure changes
4. **Review Documentation**: Keep guides current with actual deployments

---

## 📞 Support

For questions or issues:
- **Internal Team**: IT Infrastructure Team
- **Documentation Issues**: Open an issue in this repository
- **Automation**: See `src-ansible-win` repository

---

**Last Updated**: January 2026  
**Maintainer**: IT Infrastructure Team  
**Repository**: `product-windows-server`
