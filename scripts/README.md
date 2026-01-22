# Windows Server Research Scripts

PowerShell scripts for remote server research and inventory collection.

---

## 📋 Overview

These scripts connect to Windows servers via SMB to inventory file systems, applications, and services. Output is saved to local cache and logs for analysis.

---

## 🔧 Scripts

**PowerShell Version**: All scripts use **PowerShell Core (pwsh)** unless they require Windows-specific APIs.

### `Get-RemoteDriveInventory.ps1`

Main script to inventory remote server E: drives via SMB.

**Requirements**: PowerShell Core 7.0+ (pwsh)

**Usage**:
```powershell
pwsh .\Get-RemoteDriveInventory.ps1 -ServerName "EG-INTEGRATE-01" -DriveLetter "E"
pwsh .\Get-RemoteDriveInventory.ps1 -ServerName "EG-WebApps-01" -DriveLetter "E"
pwsh .\Get-RemoteDriveInventory.ps1 -ServerName "EG-WebApps-05" -DriveLetter "E"
```

**Note**: SMB connections via UNC paths require Windows or SMB client on Linux/macOS.

**Output**:
- Directory listings saved to `cache/{servername}-{drive}-inventory.json`
- Execution logs saved to `logs/{servername}-{drive}-{timestamp}.log`

---

## 📁 Directory Structure

```
scripts/
├── README.md                          # This file
├── .gitignore                         # Git ignore patterns (cache, logs)
├── Get-RemoteDriveInventory.ps1      # Main inventory script
├── cache/                             # Remote file listings (gitignored)
│   ├── EG-INTEGRATE-01-E-inventory.json
│   ├── EG-WebApps-01-E-inventory.json
│   └── EG-WebApps-05-E-inventory.json
└── logs/                              # Script execution logs (gitignored)
    ├── EG-INTEGRATE-01-E-*.log
    ├── EG-WebApps-01-E-*.log
    └── EG-WebApps-05-E-*.log
```

---

## 🔐 Authentication

**Assumption**: Windows authentication works (current user has access)

**Requirements**:
- Domain-joined machine or VPN connection
- Appropriate permissions to access E$ administrative share
- Network connectivity to target servers

---

## 📊 Research Targets

### Integration Server
- **EG-INTEGRATE-01** - E: drive
  - Custom Windows services
  - Scheduled tasks
  - Application logs
  - Integration Engine components

### Web Application Servers
- **EG-WebApps-01** - E: drive
  - Application files
  - Logs
  - **Note**: May contain deprecated apply.{school}.edu sites (not migrating)
- **EG-WebApps-05** - E: drive
  - Application files
  - Logs
  - **Note**: May contain deprecated apply.{school}.edu sites (not migrating)

---

## ⚠️ Important Notes

### Deprecated Applications

**Application Portals (apply.{school}.edu)**:
- **Status**: Deprecated in 2025, decommissioned
- **Migration**: **NOT migrating to Chicago datacenter**
- **Purpose**: Historic reference only
- If found on E: drives, document but exclude from migration planning

---

## 🚀 Quick Start

1. **Ensure PowerShell Core is installed**:
   ```bash
   # Check version
   pwsh --version
   # Should be 7.0 or higher
   ```

2. **Ensure you're on domain/VPN**:
   ```powershell
   # Test connectivity
   Test-Connection EG-INTEGRATE-01
   ```

3. **Run inventory script**:
   ```powershell
   cd scripts
   pwsh .\Get-RemoteDriveInventory.ps1 -ServerName "EG-INTEGRATE-01" -DriveLetter "E"
   ```

   Or use the batch script:
   ```powershell
   pwsh .\Invoke-AllServerInventory.ps1
   ```

3. **Review output**:
   - Check `cache/` for JSON inventory files
   - Check `logs/` for execution logs

---

## 📚 Related Documentation

- **[Application Roster](../docs/applications/roster.md)** - Application inventory
- **[Deprecated Applications](../docs/applications/roster.md#-deprecated-applications-historic-reference)** - Historic applications
- **[Current State Inventory](../docs/inventory/current-state.md)** - Server inventory

---

## 💻 PowerShell Version

**All scripts use PowerShell Core (pwsh) unless they require Windows-specific APIs.**

- **PowerShell Core 7.0+** required
- **SMB connections** work on Windows, Linux (with SMB client), macOS (with SMB client)
- **UNC paths** (`\\server\share`) require SMB support

**Why PowerShell Core?**
- Cross-platform compatibility
- Modern features and performance
- Active development and support
- Better error handling

**Windows-Specific APIs**: If a script needs Windows-only APIs, it will be clearly documented.

---

**Last Updated**: January 2026
