# CampusNexus URLs and Environments

Complete documentation of CampusNexus URLs, environments, and current state.

**Last Updated**: January 2026  
**Source**: `proj-appdev-planning/knowledge-base/campusnexus/URLS.md`

---

## Overview

CampusNexus (Anthology Student Information System) is accessed through multiple URLs across different environments (production, test, training) and school domains.

---

## Production URLs

### Production Environment

**Load Balancer**: `campusnexus.tcsedsystem.edu`  
**Status**: ✅ Operational  
**Cloudflare**: Proxied through Cloudflare Load Balancer  
**Backend**: PRD-CNWEB-01, 02, 03 (Windows/IIS) - Planned / EG-CNWEB-01, 02, 03 (Windows/IIS) - Current

**School-Specific Production URLs**:
- `campusnexus.thechicagoschool.edu` - The Chicago School
- `campusnexus.pacificoaks.edu` - Pacific Oaks College
- `campusnexus.saybrook.edu` - Saybrook University
- `campusnexus.collegesoflaw.edu` - The College of Law
- `campusnexus.kansashsc.org` - Kansas Health Science Center

**All production URLs**:
- Route through Cloudflare Load Balancer
- Use cloudflared Windows services (current)
- Target: Migrate to unified RHEL tunnel architecture

---

## Test Environment

### Current State (Workaround)

**⚠️ Load Balancer Offline**: The Cloudflare Load Balancer for test environment has been **offline since an upgrade**.

**Workaround URL**: `newtestnexus.tcsedsystem.edu`
- **Implementation**: Simple LAN DNS direct to single origin server
- **Status**: ✅ Operational (workaround)
- **Duration**: Running like this for years
- **Backend**: Direct DNS A record pointing to single test origin server
- **No Load Balancing**: Single server, no failover
- **No Cloudflare**: Direct access, bypasses Cloudflare

**Original Test URL** (Offline):
- `testnexus-lb.tcsedsystem.edu` - Cloudflare Load Balancer
- **Status**: ❌ Offline (since upgrade)
- **Issue**: Load balancer configuration broken/disabled

### Test Environment Details

**Current Workaround**:
```
newtestnexus.tcsedsystem.edu
  ↓
LAN DNS (A record)
  ↓
Single Test Origin Server (direct access)
```

**Original Design** (Offline):
```
testnexus-lb.tcsedsystem.edu
  ↓
Cloudflare Load Balancer
  ↓
Test Origin Pool (multiple servers)
```

### Issues with Current Workaround

1. **No Load Balancing**: Single point of failure
2. **No Cloudflare Protection**: No CDN, WAF, DDoS protection
3. **No High Availability**: No failover if server goes down
4. **Inconsistent Naming**: `newtestnexus` vs standard naming
5. **Direct Access**: Bypasses security layers

---

## Training Environment

**Load Balancer**: `trainnexus-lb.tcsedsystem.edu`  
**Status**: ✅ Operational  
**Cloudflare**: Proxied through Cloudflare Load Balancer  
**Backend**: Training origin pool

**Configuration**:
- Session Affinity: Cookie-based (TTL: 604800 seconds)
- Steering Policy: Dynamic latency
- Multiple training origin servers

---

## URL Summary

| Environment | URL | Status | Type | Notes |
|-------------|-----|--------|------|-------|
| **Production** | `campusnexus.tcsedsystem.edu` | ✅ Operational | Cloudflare LB | All schools |
| **Production** | `campusnexus.{school}.edu` | ✅ Operational | Cloudflare LB | 5 school domains |
| **Test** | `testnexus-lb.tcsedsystem.edu` | ❌ Offline | Cloudflare LB | Broken since upgrade |
| **Test** | `newtestnexus.tcsedsystem.edu` | ✅ Operational | Direct DNS | Workaround (years) |
| **Training** | `trainnexus-lb.tcsedsystem.edu` | ✅ Operational | Cloudflare LB | Training environment |

---

## Planned Improvements

### Test Environment Restoration

**Goal**: Reinstate proper test URL with new buildout

**Options**:

#### Option 1: Restore Cloudflare Load Balancer
- Fix/restore `testnexus-lb.tcsedsystem.edu` load balancer
- Reconfigure test origin pool
- Migrate from `newtestnexus.tcsedsystem.edu` back to `testnexus-lb.tcsedsystem.edu`

#### Option 2: Migrate to Cloudflare Tunnel
- Include test environment in unified tunnel architecture
- Use `testnexus.tcsedsystem.edu` (standard naming)
- Route through PRD-CFTunnel or dedicated test tunnel
- Eliminate need for load balancer

#### Option 3: Hybrid Approach
- Keep `newtestnexus.tcsedsystem.edu` for internal/LAN access
- Add `testnexus.tcsedsystem.edu` through Cloudflare Tunnel for external access
- Gradual migration path

### Recommended Approach

**Preferred**: Option 2 (Cloudflare Tunnel)

**Benefits**:
- ✅ Consistent with production architecture
- ✅ Standard naming (`testnexus.tcsedsystem.edu`)
- ✅ Unified management
- ✅ Better security (no direct access)
- ✅ Aligns with new buildout goals

---

## Related Documentation

- **[CampusNexus Overview](README.md)** - Complete CampusNexus documentation
- **[Application Roster](../roster.md)** - Complete application inventory
- **[Architecture](../architecture.md)** - Overall architecture

---

**Last Updated**: January 2026
