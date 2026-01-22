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
    [string]$ScriptPath = ".\Get-RemoteDriveInventory.ps1"
)

$ErrorActionPreference = "Continue"

# Target servers for E: drive inventory
$targetServers = @(
    @{ ServerName = "EG-INTEGRATE-01"; DriveLetter = "E"; Description = "Integration Server" },
    @{ ServerName = "EG-WebApps-01"; DriveLetter = "E"; Description = "Web Applications Server #1" },
    @{ ServerName = "EG-WebApps-05"; DriveLetter = "E"; Description = "Web Applications Server #5" }
)

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
    Write-Host "  Drive: $($server.DriveLetter):" -ForegroundColor Gray
    Write-Host ""
    
    try {
        & $ScriptPath -ServerName $server.ServerName -DriveLetter $server.DriveLetter
        
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
