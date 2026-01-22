# Documentation Questions

Questions that need answers to complete Windows server documentation.

**Last Updated**: January 2026

---

## Application Roster Questions

### Custom Applications on EG-WebApps-*

**Question 1**: Which specific applications are hosted on each EG-WebApps server?
- EG-WebApps-01: ?
- EG-WebApps-02: ?
- EG-WebApps-03: ?
- EG-WebApps-04: ?
- EG-WebApps-05: ?
- EG-WebApps-06: ?
- EG-WebApps-07: ?
- EG-WebApps-08: ?

**Question 2**: What is the mapping for consolidation to PRD-WebApps-01-04?
- Which EG-WebApps servers will be consolidated into each PRD-WebApps server?
- Are there specific applications that should be grouped together?

### Application Details

**Question 3**: What are the specific URLs for custom applications?
- Support Desk: `apps.tcsedsystem.edu` - confirmed?
- Integration System: `integration.tcsedsystem.edu` - confirmed?
- Are there other custom application URLs not listed in SensitiveApplications.md?

**Question 4**: Which applications from the GitHub repos are actually deployed to Windows servers?
- `src-net-academic-portal` - Deployed to which server?
- `src-net-cashierservice` - Deployed to which server?
- `src-nodejs-tcses-powertools` - Deployed to which server?
- `src-net-applicationportal` - Deployed to which server?
- `src-net-onprem-task-processing-service` - Deployed to which server?

### Integration Servers

**Question 5**: What specific applications/services run on integration servers (EG-Integrate-01)?
- Integration Engine - confirmed?
- What other Windows services?
- What scheduled tasks?
- What applications with logs on E: drive?

**Note**: EG-Integrate-01 is a new server (only 6 months old) and will be migrated via backup restore.

---

## Architecture Questions

### Server Specifications

**Question 6**: What are the hardware specifications for PRD-* servers?
- CPU, RAM, Storage
- VMware VM configuration
- Network configuration

**Question 7**: What Windows Server version and IIS version?
- Windows Server 2022?
- IIS 10?
- .NET Framework versions?

### Network Architecture

**Question 8**: What are the IP addresses and subnets for PRD-* servers?
- PRD-CNWEB-01, 02, 03: IP addresses?
- PRD-CVAPI-01: IP address?
- PRD-CNPORT-01: IP address?
- PRD-WebApps-01, 02, 03, 04: IP addresses? (I see 10.70.138.41-44 mentioned)
- Subnet configuration?

### Cloudflare Tunnel Configuration

**Question 9**: How will Cloudflare Tunnel route to specific applications?
- Localhost file pointers - what format?
- Per-application routing rules?
- Load balancing between multiple origin servers?

---

## CampusNexus Questions

### Test Environment

**Question 10**: What is the actual test server hostname/IP for `newtestnexus.tcsedsystem.edu`?
- Which server is it pointing to?
- Is it a single server or multiple?

**Question 11**: What is the plan for test environment migration?
- Will test use PRD-CFTunnel or dedicated TST-CFTunnel?
- Will test servers be TST-CNWEB-* or use different naming?

### Training Environment

**Question 12**: What are the training environment server details?
- Server hostnames/IPs?
- How many servers?
- Will training be migrated to Chicago or stay in current location?

---

## Perceptive Content Questions

**Question 13**: What is the complete Perceptive Content architecture?
- How many Perceptive Content servers?
- What are their roles (web, application, database)?
- Will Perceptive Content be migrated to Chicago?

---

## Application Deployment Questions

**Question 14**: What is the deployment process for each application?
- GitHub Actions workflows?
- Manual deployment?
- Web Deploy?
- Other methods?

**Question 15**: What are the service account requirements per application?
- Which applications use domain service accounts?
- What are the service account names?
- What folder permissions are required?

---

## Monitoring and Logging Questions

**Question 16**: What monitoring is in place beyond Datadog?
- LogicMonitor - what is monitored?
- Azure Arc - what is monitored?
- Other monitoring tools?

**Question 17**: What are the log file locations for each application?
- Application logs under web root `/logs`?
- Other log locations?
- E: drive logs (for integration servers)?

---

## Migration Timeline Questions

**Question 18**: What is the target timeline for migration?
- Phase 1 (Infrastructure): Target date?
- Phase 2 (Test): Target date?
- Phase 3 (Production): Target date?
- Phase 4 (Decommission): Target date?

**Question 19**: What are the dependencies for migration?
- Database migration required?
- DNS cutover windows?
- Application-specific migration requirements?

---

## Please Answer

Please provide answers to these questions so I can complete the documentation accurately. I'll update the documentation files with the information provided.

**Priority Questions** (for immediate documentation):
1. Application mapping to EG-WebApps servers (Question 1, 2)
2. IP addresses for PRD-* servers (Question 7)
3. Test environment server details (Question 10)
4. Application deployment methods (Question 14)

---

**Last Updated**: January 2026
