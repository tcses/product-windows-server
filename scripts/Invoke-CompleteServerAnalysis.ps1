#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Run complete server analysis on all target servers.

.DESCRIPTION
    Executes all analysis scripts (drive inventory, IIS config, services) for
    all research target servers.

.EXAMPLE
    .\Invoke-CompleteServerAnalysis.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ScriptDir = "."
)

$ErrorActionPreference = "Continue"

# Target servers for complete analysis
$targetServers = @(
    @{ ServerName = "EG-INTEGRATE-01"; Description = "Integration Server" },
    @{ ServerName = "EG-WebApps-01"; Description = "Web Applications Server #1" },
    @{ ServerName = "EG-WebApps-05"; Description = "Web Applications Server #5" }
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Complete Windows Server Analysis" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalServers = $targetServers.Count
$currentServer = 0

foreach ($server in $targetServers) {
    $currentServer++
    
    Write-Host "[$currentServer/$totalServers] Processing: $($server.ServerName)" -ForegroundColor Yellow
    Write-Host "  Description: $($server.Description)" -ForegroundColor Gray
    Write-Host ""
    
    # 1. E: Drive Inventory
    Write-Host "  [1/3] E: Drive Inventory..." -ForegroundColor Cyan
    try {
        & "$ScriptDir\Get-RemoteDriveInventory.ps1" -ServerName $server.ServerName -DriveLetter "E"
        if ($LASTEXITCODE -eq 0 -or $?) {
            Write-Host "    ✓ Success" -ForegroundColor Green
        } else {
            Write-Host "    ✗ Failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 2. IIS Configuration
    Write-Host "  [2/3] IIS Configuration..." -ForegroundColor Cyan
    try {
        & "$ScriptDir\Get-IISConfiguration.ps1" -ServerName $server.ServerName
        if ($LASTEXITCODE -eq 0 -or $?) {
            Write-Host "    ✓ Success" -ForegroundColor Green
        } else {
            Write-Host "    ✗ Failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 3. Services & Scheduled Tasks
    Write-Host "  [3/3] Services & Scheduled Tasks..." -ForegroundColor Cyan
    try {
        & "$ScriptDir\Get-ServerServices.ps1" -ServerName $server.ServerName
        if ($LASTEXITCODE -eq 0 -or $?) {
            Write-Host "    ✓ Success" -ForegroundColor Green
        } else {
            Write-Host "    ✗ Failed" -ForegroundColor Red
        }
    } catch {
        Write-Host "    ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All servers analyzed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check cache/ folder for all inventory files:" -ForegroundColor Green
Write-Host "  - *-E$-inventory.json (Drive listings)" -ForegroundColor Cyan
Write-Host "  - *-IIS-config.json (IIS configuration)" -ForegroundColor Cyan
Write-Host "  - *-Services-config.json (Services & tasks)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check logs/ folder for execution logs" -ForegroundColor Green
Write-Host ""
