# Inventory Script Guide

Documentation for configuring and running the Windows Server inventory scripts.

---

## Purpose

These scripts collect read-only inventory data from Windows servers to support documentation and planning. They do **not** modify remote systems.

---

## Configuration

Server targets live in:

- `config/inventory/servers.json`

Example schema:

```json
{
  "servers": [
    {
      "serverName": "EG-INTEGRATE-01",
      "appsDriveLetter": "E",
      "description": "Integration Server",
      "role": "Integration Services",
      "environment": "Production"
    }
  ]
}
```

Field notes:
- `serverName` is required.
- `appsDriveLetter` defaults to `E` if omitted.
- Additional metadata (role, environment, owner) is allowed and ignored by scripts unless documented.

---

## Scripts

### `Get-RemoteDriveInventory.ps1`

Runs inventory for a single server/drive. Supports SMB or PowerShell Remoting.

Common usage (remoting with depth limit):

```powershell
pwsh .\Get-RemoteDriveInventory.ps1 -ServerName "EG-INTEGRATE-01" -DriveLetter "E" -UseRemoting $true -MaxDepth 4
```

### `Invoke-AllServerInventory.ps1`

Runs inventory against all servers in `config/inventory/servers.json`.

```powershell
pwsh .\Invoke-AllServerInventory.ps1 -InventoryConfigPath "..\config\inventory\servers.json" -UseRemoting $true -MaxDepth 4
```

---

## Output

- Cache JSON: `scripts/cache/{server}-{drive}-inventory.json`
- Logs: `scripts/logs/{server}-{drive}-{timestamp}.log`

These directories are gitignored.

---

## Remoting vs SMB

- **Remoting (default)**: Faster for large directory trees and avoids SMB overhead.
- **SMB**: Use `-UseRemoting $false` if WinRM is unavailable.

---

## Notes

- PowerShell 7+ required.
- Requires network/VPN access and permissions for the target servers.
