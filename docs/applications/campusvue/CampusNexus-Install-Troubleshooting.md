# CampusNexus Install Troubleshooting

Quick-reference troubleshooting notes for CampusNexus (Anthology) installs and common runtime failures.

Sources digested from `C:\git\product-anthology-student\docs\kb\hosting`.

---

## Installation Manager Notes

- Import the Installation Manager settings export for known-good defaults.
- If using older exports, **reinstall or update SSL certificates** before reuse.

---

## Prerequisites Checklist

### Network / Firewall

- If firewall cannot be disabled, ensure these ports are open:
  - TCP 135 (RPC/WMI)
  - TCP 139 / 445 (Windows File Sharing)
  - UDP 137 / 138 (NetBIOS)
  - TCP 8889-8890 (Installation Manager Agent)
  - TCP 1433 (SQL)
- Enable Windows Management Instrumentation (DCOM-In, WMI-In) firewall rules.

### Local Security Policy

- Disable UAC "Run all administrators in Admin Approval Mode".

### IIS / Windows Features

- .NET Framework 4.7+ application development components
- WCF HTTP Activation
- WebSocket support
- Application Initialization (keep site warm)

### Anti-Malware

- Allow PowerShell script execution from the CampusNexus install folder.

---

## Common Install Errors

### WCF HTTP Activation Missing

Symptoms:
- Web client error pointing to WCF Web Services

Fix:
- Enable **Windows Communication Foundation HTTP Activation** in IIS features.

### Microsoft.Build.Tasks 2.0 Error

Symptoms:
- Build tasks failure due to legacy .NET components

Fix:
- Install .NET 3.5 components. On Server 2019 this may require a mounted ISO.

---

## Staff STS Troubleshooting

### Relying Parties Misconfigured

Symptoms:
- Staff STS error about relying parties

Fix:
- Update relying parties in `web.config` or via IIS config UI.

### API Endpoint Misconfigured

Symptoms:
- Staff STS error pointing to API server endpoint

Fix:
- Ensure the API endpoint in `web.config` points to the correct API server.

### Clock Skew Errors

Symptoms:
- "Specified Argument was out of the range of valid values. Parameter name: validFrom"

Fix:
- Sync server time with domain controller.
- Ensure Windows Time Service is running and set to automatic.

---

## SSL Management (CampusNexus)

> **Important**  
> Certificate rotation touches **IIS bindings** *and* **web.config thumbprints** in multiple components.

### Certificate Install Workflow

1. Import the `.pfx` into **LocalMachine\My (Personal)** on target web servers.
2. Export the `.cer` public cert and use **Installation Manager "Browse Certificate"** to read the SHA-1 thumbprint.
3. Bind IIS site(s) to the new certificate.

### Required Thumbprint Updates

- Update **Staff STS** and **Web Client** `web.config` thumbprints.
- After update, recycle the **Staff STS** app pool.

### Private Key Permissions

- Grant private key access to `IIS_IUSRS` for the new cert.

### Known Pitfall: Login Development Mode

Symptoms:
- "Login Development Mode" screen after reinstall

Likely cause:
- WSFed certificate thumbprint mismatch between Staff STS and Web Client.

Fix:
- Compare and align thumbprints in both `web.config` files.

### Last-Resort Rotation

If IIS binding and thumbprints do not take effect:
- Uninstall + reinstall **Staff STS**, then **Web Client**.

---

## Cloudflare + WAF + DNS Notes

### Hosting Stack Snapshot

- CampusNexus Web Client runs on on-prem IIS servers.
- Traffic is protected by Cloudflare (CDN/WAF) and then load balanced.

### True Client IP Logging (IIS)

Add custom IIS log fields to preserve original client IP and request context:

- `CF-Connecting-IP`
- `True-Client-IP`
- `X-Forwarded-For`
- `CF-RAY`
- `CF-IPCountry`

### Cisco ASA Whitelist

- Allow inbound 443 traffic only from Cloudflare IP ranges.
- Include Railgun/Argo proxy IPs if still in use (historically `65.52.58.163`).

### Cloudflare Page Rules

Rocket Loader can break the Staff STS Content Security Policy:

- Symptom: CSP blocks `rocket-loader.min.js`
- Fix: Disable Rocket Loader for Staff STS hostnames via Page Rules

### Railgun Deprecation

- Railgun is deprecated.
- Current proxy/tunneling uses Cloudflared (documented elsewhere).

---

## Logging

- Set `nlog.config` to `trace`.
- Create `/log/` in Staff STS web root and grant write permissions for `IIS_IUSRS`.

---

## Source References

- `CampusNexus Web Client – Server Install.md`
- `CampusNexus Staff STS Install.md`
- `CampusNexus – Core API Services.md`
- `CampusNexus Legacy Prerequisites.md`
