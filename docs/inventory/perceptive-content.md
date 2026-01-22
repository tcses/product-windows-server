# Perceptive Content Server Inventory

Complete inventory and documentation for Perceptive Content (ImageNow/WebNow) document management system servers.

**Last Updated**: January 2026  
**Status**: Active Production

---

## 📋 Overview

Perceptive Content (formerly ImageNow) is the document management system used for:
- Student records
- Administrative documents
- Document storage and retrieval
- Integration with CampusVue/CampusNexus

**Product Name**: Perceptive Content (also referred to as "WebNow" for web interface)

---

## 🖥️ Current Servers

### Perceptive Content Web Server

| Server Name | Hostname | IP Address | Purpose | Status | Notes |
|-------------|----------|------------|---------|--------|-------|
| EG-INOWWEB | EG-INOWWEB.TCSES.ORG | - | Perceptive Content Web | 🟢 Active | WebNow/Perceptive Content web server |

**Applications**:
- Perceptive Content web interface (WebNow)
- Document management services
- Integration endpoints

**URL**: `webnow.tcsedsystem.edu`

**Port**: 443 (HTTPS)

---

## 🏗️ Architecture

### Current Architecture

```
Internet
   ↓
Direct Access (HTTPS)
   ↓
EG-INOWWEB.TCSES.ORG (Windows/IIS)
   ↓
Perceptive Content Application
```

**Note**: Currently direct access (no reverse proxy in production)

### Planned Architecture

```
Internet
   ↓
NGINX Reverse Proxy (RHEL)
   ↓
EG-INOWWEB.TCSES.ORG (Windows/IIS)
   ↓
Perceptive Content Application
```

**Planned Reverse Proxy**: PRD-NGINX-Perceptive (RHEL NGINX server)

**See Also**: [proj-appdev-planning/knowledge-base/rhel-nginx-internal-proxy/](../../../proj-appdev-planning/knowledge-base/rhel-nginx-internal-proxy/README.md)

---

## 🔧 Configuration

### IIS Configuration

**Server**: Windows Server with IIS
**Application Pool**: Perceptive Content application pool
**Port**: 443 (HTTPS)
**SSL Certificate**: Managed certificate

### Integration Points

**CampusVue/CampusNexus**:
- Document storage integration
- Student record linking
- API endpoints for document retrieval

**Other Systems**:
- Various administrative systems
- Document import/export services

---

## 🔄 Migration Status

**Current**: EG-INOWWEB (Elk Grove datacenter)

**Future State**: TBD
- May remain on EG-INOWWEB
- Or migrate to new server (TBD naming)
- Reverse proxy via PRD-NGINX-Perceptive (planned)

**Status**: 🟡 To Be Determined

---

## 📚 Related Documentation

- **[proj-appdev-planning/knowledge-base/rhel-nginx-internal-proxy/](../../../proj-appdev-planning/knowledge-base/rhel-nginx-internal-proxy/README.md)** - NGINX reverse proxy for Perceptive Content
- **[Current State Inventory](current-state.md)** - Complete current server inventory
- **[Future State Inventory](future-state.md)** - Planned migration servers

---

## 🔍 Additional Information

**Product Details**:
- **Vendor**: Perceptive Software (now part of Hyland)
- **Product**: Perceptive Content (formerly ImageNow)
- **Web Interface**: WebNow
- **Version**: (To be documented)

**Access**:
- **URL**: `webnow.tcsedsystem.edu`
- **Protocol**: HTTPS
- **Authentication**: (To be documented)

---

**Last Updated**: January 2026  
**Note**: Additional Perceptive Content server details to be added as information becomes available
