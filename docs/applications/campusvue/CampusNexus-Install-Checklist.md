# CampusNexus Install Checklist

Practical checklist distilled from legacy hosting KB notes. Use for new installs or rebuilds.

---

## Installation Manager

- Import the Installation Manager settings export for known-good defaults.
- Reinstall or update SSL certificates before reusing old exports.

---

## Network / Firewall

If firewall cannot be disabled, ensure these ports are open:

| Port | Protocol | Purpose |
| --- | --- | --- |
| 135 | TCP | RPC/WMI |
| 139 | TCP | Windows file sharing |
| 445 | TCP | Windows file sharing |
| 137 | UDP | NetBIOS |
| 138 | UDP | NetBIOS |
| 8889-8890 | TCP | Installation Manager Agent |
| 1433 | TCP | SQL Server |

Also enable:

- Windows Management Instrumentation rules (DCOM-In, WMI-In)
- VLAN-to-VLAN rule for RPC 135 if installer and targets are separate

---

## Local Security Policy

- Disable UAC "Run all administrators in Admin Approval Mode".

---

## Windows / IIS Features

- .NET Framework 4.7+ application development components
- WCF HTTP Activation
- WebSocket support
- Application Initialization (warmup after reboot)

---

## Antivirus / EDR

- Allow PowerShell execution from the CampusNexus installation folder.

---

## SSL Certificate Prep

1. Import `.pfx` into **LocalMachine\My (Personal)** on target web servers.
2. Export `.cer` public cert for Installation Manager "Browse Certificate" step.
3. Ensure the cert is usable for IIS binding and thumbprint updates.

---

## Runtime Validation

- Verify components and versions in **Programs and Features**.
- Confirm `web.config` appSettings via IIS UI where needed.
- Enable logging (see troubleshooting doc).

---

## Legacy Test Environment Reference

Historical test environment notes from legacy KB:

- HQ-CNWEB1 / HQ-CNWEB2: Staff STS + Web Client
- HQ-CVAPI1-T: API server
- Test hostnames routed through internal DNS + load balancer

These are reference-only and may be outdated.
