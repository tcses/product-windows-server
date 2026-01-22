# Migration Planning - Elk Grove to Chicago

Complete migration plan for Windows Server infrastructure from Elk Grove (EG-*) to Chicago (PRD-*) datacenter.

**Last Updated**: January 2026  
**Source**: `proj-appdev-planning/app-dev-planning/web-services-migration/`

---

## 📋 Overview

Migration of Windows Server infrastructure from Elk Grove colocation to Chicago datacenter, including:

- **CampusNexus Cluster** - Student Information System
- **Custom Application Servers** - Custom .NET web applications
- **Integration Servers** - Windows services and scheduled tasks

**Architecture Change**: F5 BIG-IP → Cloudflare Tunnel (RHEL)

---

## 🎯 Migration Goals

1. **Eliminate F5 BIG-IP** - Replace with Cloudflare Tunnel
2. **Consolidate Servers** - 13 → 9 Windows servers (31% reduction)
3. **Unified Architecture** - Single proxy layer for all IIS hosting
4. **Enhanced Security** - No public IPs, encrypted tunnel
5. **Cost Reduction** - Eliminate F5 licensing and maintenance

---

## 📊 Server Mapping

### CampusNexus Cluster

| Current (Elk Grove) | Target (Chicago) | Status |
|---------------------|-------------------|--------|
| EG-CNWEB-01 | PRD-CNWEB-01 | 🟡 Planned |
| EG-CNWEB-02 | PRD-CNWEB-02 | 🟡 Planned |
| EG-CNWEB-03 | PRD-CNWEB-03 | 🟡 Planned |
| EG-CVAPI-01 | PRD-CVAPI-01 | 🟡 Planned |
| EG-CNPORT-01 | PRD-CNPORT-01 | 🟡 Planned |

### Custom Application Servers

| Current (Elk Grove) | Target (Chicago) | Status | Consolidation |
|---------------------|-------------------|--------|---------------|
| EG-WebApps-01, 02 | PRD-WebApps-01 | 🟡 Planned | 2 → 1 |
| EG-WebApps-03, 04 | PRD-WebApps-02 | 🟡 Planned | 2 → 1 |
| EG-WebApps-05, 06 | PRD-WebApps-03 | 🟡 Planned | 2 → 1 |
| EG-WebApps-07, 08 | PRD-WebApps-04 | 🟡 Planned | 2 → 1 |

**Consolidation**: 8 servers → 4 servers (**50% reduction**)

### Integration Servers

| Current (Elk Grove) | Target (Chicago) | Status | Migration Method |
|---------------------|-------------------|--------|------------------|
| EG-Integrate-01 | PRD-Integrate-01 | 🟡 Planned | Backup restore (clone) |

**Note**: EG-Integrate-01 is a new server (only 6 months old at Elk Grove). Migration will be via backup restore/clone method rather than fresh build.

**Applications**:
- Custom Windows services
- Scheduled tasks
- Background processing
- Integration Engine
- Application logs (E: drive)

---

## 🏗️ Architecture Migration

### Current Architecture (Elk Grove)

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

**Components**:
- F5 BIG-IP hardware load balancer
- Windows-local proxy services (CampusNexus)
- 14 Windows/IIS servers (including EG-Integrate-01)

### Target Architecture (Chicago)

```
Internet
   ↓
☁️ Cloudflare (CDN + WAF + DDoS + SSL)
   ↓
🔒 Cloudflare Tunnel (Encrypted)
   ↓
🐧 PRD-CFTunnel-01, 02 (RHEL 10.0 + cloudflared)
   ↓
🖥️ PRD-CNWEB-01, 02, 03 (Windows/IIS)
🖥️ PRD-CVAPI-01 (Windows/IIS)
🖥️ PRD-CNPORT-01 (Windows/IIS)
🖥️ PRD-WebApps-01, 02, 03, 04 (Windows/IIS)
```

**Components**:
- Cloudflare CDN/WAF (replaces F5)
- Cloudflare Tunnel on RHEL (replaces Windows-local proxies)
- 10 Windows/IIS servers (consolidated from 14, plus EG-Integrate-01 → PRD-Integrate-01)

---

## 📅 Migration Phases

### Phase 1: Infrastructure Setup

**Tasks**:
- [ ] Deploy Cloudflare Tunnel servers (PRD-CFTunnel-01, 02)
- [ ] Configure Cloudflare Tunnel endpoints
- [ ] Test connectivity and routing
- [ ] Validate tunnel configuration

**Timeline**: TBD

### Phase 2: Test Environment

**Tasks**:
- [ ] Deploy test servers (TST-CNWEB-*, TST-WebApps-*)
- [ ] Configure Cloudflare Tunnel for test
- [ ] Validate applications and integrations
- [ ] Test load balancing and failover

**Timeline**: TBD

### Phase 3: Production Migration

**Tasks**:
- [ ] Deploy production CampusNexus servers (PRD-CNWEB-*, PRD-CVAPI-*, PRD-CNPORT-*)
- [ ] Deploy production web application servers (PRD-WebApps-*)
- [ ] Configure Cloudflare Tunnel for production
- [ ] Migrate applications and data
- [ ] Cutover from EG-* to PRD-* servers

**Timeline**: TBD

### Phase 4: Decommission

**Tasks**:
- [ ] Decommission Elk Grove servers (EG-*)
- [ ] Remove F5 BIG-IP load balancer
- [ ] Complete migration documentation
- [ ] Update all references

**Timeline**: TBD

---

## 🔄 Migration Strategy

### Application Migration

**CampusNexus**:
- Vendor-managed application
- Coordinate with Anthology support
- Database migration required
- Configuration migration

**Custom Applications**:
- Application code deployment
- Configuration updates
- Database migration (if applicable)
- Integration testing

### Data Migration

**Databases**:
- SQL Server cluster migration
- Data synchronization
- Cutover planning

**File Systems**:
- Application files
- Log files
- Configuration files

**Integration Server**:
- **EG-Integrate-01 → PRD-Integrate-01**: Backup restore/clone method
- Full server backup and restore
- Preserve Windows services configuration
- Preserve scheduled tasks
- Preserve E: drive logs structure

### DNS Migration

**DNS Updates**:
- Update DNS records to point to new servers
- Cloudflare DNS configuration
- DNS propagation planning

---

## ⚠️ Risks and Mitigation

### Risk: Application Downtime

**Mitigation**:
- Phased migration approach
- Parallel running (EG-* and PRD-*)
- Rollback plan

### Risk: Data Loss

**Mitigation**:
- Comprehensive backup strategy
- Data validation
- Rollback procedures

### Risk: Integration Failures

**Mitigation**:
- Integration testing in test environment
- Staged cutover
- Monitoring and alerting

---

## 📚 Related Documentation

- **[Architecture Overview](architecture.md)** - Overall architecture
- **[Application Roster](../applications/roster.md)** - Application inventory
- **[Inventory - Current State](../inventory/current-state.md)** - Current servers
- **[Inventory - Future State](../inventory/future-state.md)** - Target servers

---

**Last Updated**: January 2026
