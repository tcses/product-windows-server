#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Run inventory on all target servers (EG-INTEGRATE-01, EG-WebApps-01, EG-WebApps-05).

.DESCRIPTION
    Executes Get-RemoteDriveInventory.ps1 for all research target servers.

.EXAMPLE
    .\Invoke-AllServerInventory.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ScriptPath = ".\Get-RemoteDriveInventory.ps1",
    
    [Parameter(Mandatory=$false)]
    [string]$InventoryConfigPath = "..\config\inventory\servers.json",
    
    [Parameter(Mandatory=$false)]
    [int]$MaxDepth = 4,
    
    [Parameter(Mandatory=$false)]
    [bool]$UseRemoting = $true,
    
    [Parameter(Mandatory=$false)]
    [bool]$IncludeFiles = $true
)

$ErrorActionPreference = "Continue"

# Load target servers from inventory config
if (-not (Test-Path $InventoryConfigPath)) {
    throw "Inventory config not found: $InventoryConfigPath"
}

try {
    $configContent = Get-Content -Path $InventoryConfigPath -Raw
    $config = $configContent | ConvertFrom-Json
} catch {
    throw "Failed to parse inventory config: $InventoryConfigPath. $($_.Exception.Message)"
}

if (-not $config.servers -or $config.servers.Count -eq 0) {
    throw "Inventory config has no servers: $InventoryConfigPath"
}

$targetServers = $config.servers

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Server E: Drive Inventory" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalServers = $targetServers.Count
$currentServer = 0

foreach ($server in $targetServers) {
    $currentServer++
    
    Write-Host "[$currentServer/$totalServers] Processing: $($server.ServerName)" -ForegroundColor Yellow
    Write-Host "  Description: $($server.Description)" -ForegroundColor Gray
    $driveLetter = if ($server.appsDriveLetter) { $server.appsDriveLetter } elseif ($server.DriveLetter) { $server.DriveLetter } else { "E" }

    Write-Host "  Drive: ${driveLetter}:" -ForegroundColor Gray
    Write-Host "  Scan Method: $(if ($UseRemoting) { 'Remoting' } else { 'SMB' })" -ForegroundColor Gray
    Write-Host "  Max Depth: $MaxDepth" -ForegroundColor Gray
    Write-Host "  Include Files: $([bool]$IncludeFiles)" -ForegroundColor Gray
    Write-Host ""
    
    try {
        if (-not $server.ServerName) {
            throw "ServerName missing in inventory config entry."
        }

        & $ScriptPath -ServerName $server.ServerName -DriveLetter $driveLetter -MaxDepth $MaxDepth -UseRemoting $UseRemoting -IncludeFiles $IncludeFiles
        
        if ($LASTEXITCODE -eq 0 -or $?) {
            Write-Host "  ✓ Success" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Failed (check logs)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All servers processed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check cache/ folder for inventory JSON files" -ForegroundColor Green
Write-Host "Check logs/ folder for execution logs" -ForegroundColor Green
Write-Host ""
