# Windows Server Inventory

Complete inventory of Windows Server infrastructure, including current production/test servers and planned future state servers.

---

## 📋 Overview

This directory contains comprehensive inventory documentation for:

- **Current State** - Active production and test servers (Elk Grove - EG-* naming)
- **Future State** - Planned migration servers (Chicago - PRD-* naming)
- **Perceptive Content** - Document management system servers

---

## 📚 Documentation

### Current State

**[current-state.md](current-state.md)** - Active production and test servers

**Categories**:
- CampusVue/CampusNexus Web Servers (EG-CNWEB-*)
- CampusVue API Servers (EG-CVAPI-*)
- CampusVue Portal Servers (EG-CNPORT-*)
- Custom Web Application Servers (EG-WebApps-*)
- Perceptive Content Servers (EG-INOWWEB)

### Future State

**[future-state.md](future-state.md)** - Planned migration servers

**Categories**:
- Production CampusVue Servers (PRD-CNWEB-*, PRD-CVAPI-*, PRD-CNPORT-*)
- Production Web Application Servers (PRD-WebApps-*)
- Test Servers (TST-CNWEB-*, TST-WebApps-*)

### Perceptive Content

**[perceptive-content.md](perceptive-content.md)** - Perceptive Content server inventory

**Includes**:
- Current Perceptive Content servers
- Architecture and configuration
- Integration points

---

## 🔄 Migration Status

**Elk Grove → Chicago Migration**:
- **Current**: EG-* servers (Elk Grove datacenter)
- **Target**: PRD-* servers (Chicago datacenter)
- **Status**: In planning/deployment phase

See [future-state.md](future-state.md) for detailed migration planning.

---

## 📊 Quick Reference

| Category | Current Servers | Future Servers | Status |
|----------|----------------|----------------|--------|
| CampusVue Web | EG-CNWEB-01, 02, 03 | PRD-CNWEB-01, 02, 03 | 🟡 Migration Planned |
| CampusVue API | EG-CVAPI-01 | PRD-CVAPI-01 | 🟡 Migration Planned |
| CampusVue Portal | EG-CNPORT-01 | PRD-CNPORT-01 | 🟡 Migration Planned |
| Web Applications | EG-WebApps-01-08 | PRD-WebApps-01-04 | 🟡 Migration Planned |
| Perceptive Content | EG-INOWWEB | TBD | 🟡 To Be Documented |

---

**Last Updated**: January 2026
