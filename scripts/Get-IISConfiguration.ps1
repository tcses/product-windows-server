#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Reverse engineer IIS configuration from remote Windows server.

.DESCRIPTION
    Connects to remote server via WinRM and exports complete IIS configuration
    including sites, bindings, application pools, custom settings, and more.
    Output saved to JSON cache and execution log.

.PARAMETER ServerName
    Target server name (e.g., EG-INTEGRATE-01, EG-WebApps-01)

.PARAMETER CacheDir
    Cache directory for output (default: .\cache)

.PARAMETER LogDir
    Log directory for execution logs (default: .\logs)

.EXAMPLE
    .\Get-IISConfiguration.ps1 -ServerName "EG-WebApps-01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerName,
    
    [Parameter(Mandatory=$false)]
    [string]$CacheDir = ".\cache",
    
    [Parameter(Mandatory=$false)]
    [string]$LogDir = ".\logs"
)

# Script configuration
$ErrorActionPreference = "Continue"
$script:LogFile = $null
$script:IISConfig = @{
    ServerName = $ServerName
    ScanDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Sites = @()
    ApplicationPools = @()
    Bindings = @()
    CustomSettings = @()
    Errors = @()
}

# Ensure cache and log directories exist
if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    Write-Host "Created cache directory: $CacheDir" -ForegroundColor Green
}

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    Write-Host "Created log directory: $LogDir" -ForegroundColor Green
}

# Initialize log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFileName = "$ServerName-IIS-$timestamp.log"
$script:LogFile = Join-Path $LogDir $logFileName

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$Level] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    
    # Write to console
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO"  { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
    
    # Write to log file
    Add-Content -Path $script:LogFile -Value $logMessage
}

function Invoke-RemoteCommand {
    param(
        [string]$ScriptBlock,
        [string]$Description
    )
    
    Write-Log "Executing: $Description" "INFO"
    
    try {
        $result = Invoke-Command -ComputerName $ServerName -ScriptBlock ([scriptblock]::Create($ScriptBlock)) -ErrorAction Stop
        return $result
    } catch {
        $errorMsg = "Error executing $Description : $($_.Exception.Message)"
        Write-Log $errorMsg "ERROR"
        $script:IISConfig.Errors += $errorMsg
        return $null
    }
}

# Main execution
Write-Log "========================================" "INFO"
Write-Log "IIS Configuration Reverse Engineering" "INFO"
Write-Log "Server: $ServerName" "INFO"
Write-Log "========================================" "INFO"

# Test connectivity
Write-Log "Testing connectivity to $ServerName..." "INFO"
if (Test-Connection -ComputerName $ServerName -Count 1 -Quiet) {
    Write-Log "Server is reachable" "INFO"
} else {
    Write-Log "WARNING: Server may not be reachable" "WARN"
}

# Test WinRM
Write-Log "Testing WinRM connection..." "INFO"
try {
    $testWinRM = Invoke-Command -ComputerName $ServerName -ScriptBlock { $true } -ErrorAction Stop
    if ($testWinRM) {
        Write-Log "WinRM connection successful" "INFO"
    }
} catch {
    Write-Log "ERROR: WinRM connection failed: $($_.Exception.Message)" "ERROR"
    Write-Log "Ensure WinRM is enabled and you have appropriate permissions" "ERROR"
    exit 1
}

# Check if WebAdministration module is available
Write-Log "Checking for WebAdministration module..." "INFO"
$checkModuleScript = @"
if (Get-Module -ListAvailable -Name WebAdministration) {
    Import-Module WebAdministration
    Write-Output "Available"
} else {
    Write-Output "NotAvailable"
}
"@

$moduleStatus = Invoke-RemoteCommand -ScriptBlock $checkModuleScript -Description "Check WebAdministration module"
if ($moduleStatus -ne "Available") {
    Write-Log "WARNING: WebAdministration module not available, using alternative methods" "WARN"
}

# Get IIS Sites
Write-Log "Collecting IIS sites..." "INFO"
$getSitesScript = @"
Import-Module WebAdministration -ErrorAction SilentlyContinue
`$sites = Get-WebSite
`$siteList = @()
foreach (`$site in `$sites) {
    `$siteInfo = @{
        Name = `$site.Name
        ID = `$site.Id
        State = `$site.State
        PhysicalPath = `$site.PhysicalPath
        ApplicationPool = `$site.ApplicationPool
        Bindings = @()
    }
    
    # Get bindings for this site
    `$bindings = Get-WebBinding -Name `$site.Name
    foreach (`$binding in `$bindings) {
        `$siteInfo.Bindings += @{
            Protocol = `$binding.Protocol
            BindingInformation = `$binding.BindingInformation
            IPAddress = `$binding.IPAddress
            Port = `$binding.Port
            HostHeader = `$binding.HostHeader
            CertificateHash = `$binding.CertificateHash
            CertificateStoreName = `$binding.CertificateStoreName
        }
    }
    
    # Get applications
    `$applications = Get-WebApplication -Site `$site.Name
    `$siteInfo.Applications = @()
    foreach (`$app in `$applications) {
        `$siteInfo.Applications += @{
            Path = `$app.Path
            ApplicationPool = `$app.ApplicationPool
            PhysicalPath = `$app.PhysicalPath
        }
    }
    
    # Get virtual directories
    `$vdirs = Get-WebVirtualDirectory -Site `$site.Name
    `$siteInfo.VirtualDirectories = @()
    foreach (`$vdir in `$vdirs) {
        `$siteInfo.VirtualDirectories += @{
            Path = `$vdir.Path
            PhysicalPath = `$vdir.PhysicalPath
        }
    }
    
    `$siteList += `$siteInfo
}
`$siteList | ConvertTo-Json -Depth 10
"@

$sitesResult = Invoke-RemoteCommand -ScriptBlock $getSitesScript -Description "Get IIS sites"
if ($sitesResult) {
    try {
        $script:IISConfig.Sites = $sitesResult | ConvertFrom-Json
        Write-Log "Found $($script:IISConfig.Sites.Count) IIS sites" "INFO"
    } catch {
        Write-Log "Error parsing sites JSON: $($_.Exception.Message)" "ERROR"
    }
}

# Get Application Pools
Write-Log "Collecting application pools..." "INFO"
$getAppPoolsScript = @"
Import-Module WebAdministration -ErrorAction SilentlyContinue
`$pools = Get-WebAppPoolState
`$poolList = @()
foreach (`$pool in `$pools) {
    `$poolInfo = @{
        Name = `$pool.Name
        State = `$pool.Value
    }
    
    # Get detailed pool configuration
    `$poolConfig = Get-ItemProperty "IIS:\AppPools\`$(`$pool.Name)"
    `$poolInfo.ManagedRuntimeVersion = `$poolConfig.managedRuntimeVersion
    `$poolInfo.ManagedPipelineMode = `$poolConfig.managedPipelineMode
    `$poolInfo.Enable32BitAppOnWin64 = `$poolConfig.enable32BitAppOnWin64
    `$poolInfo.ProcessModel = @{
        IdentityType = `$poolConfig.processModel.identityType
        UserName = `$poolConfig.processModel.userName
        IdleTimeout = `$poolConfig.processModel.idleTimeout
        MaxProcesses = `$poolConfig.processModel.maxProcesses
    }
    `$poolInfo.Recycling = @{
        PeriodicRestart = @{
            Time = `$poolConfig.recycling.periodicRestart.time
            Requests = `$poolConfig.recycling.periodicRestart.requests
            Memory = `$poolConfig.recycling.periodicRestart.memory
        }
    }
    
    `$poolList += `$poolInfo
}
`$poolList | ConvertTo-Json -Depth 10
"@

$poolsResult = Invoke-RemoteCommand -ScriptBlock $getAppPoolsScript -Description "Get application pools"
if ($poolsResult) {
    try {
        $script:IISConfig.ApplicationPools = $poolsResult | ConvertFrom-Json
        Write-Log "Found $($script:IISConfig.ApplicationPools.Count) application pools" "INFO"
    } catch {
        Write-Log "Error parsing pools JSON: $($_.Exception.Message)" "ERROR"
    }
}

# Get Custom Settings from applicationHost.config
Write-Log "Reading applicationHost.config..." "INFO"
$getConfigScript = @"
`$configPath = "C:\Windows\System32\inetsrv\config\applicationHost.config"
if (Test-Path `$configPath) {
    `$config = [xml](Get-Content `$configPath)
    
    `$customSettings = @{
        GlobalModules = @()
        Modules = @()
        Handlers = @()
        DefaultDocument = @()
        DirectoryBrowse = @{}
        HttpErrors = @()
        HttpLogging = @{}
        RequestFiltering = @{}
    }
    
    # Global modules
    if (`$config.configuration.'system.webServer'.globalModules) {
        foreach (`$module in `$config.configuration.'system.webServer'.globalModules.add) {
            `$customSettings.GlobalModules += @{
                Name = `$module.name
                Image = `$module.image
            }
        }
    }
    
    # Modules
    if (`$config.configuration.'system.webServer'.modules) {
        foreach (`$module in `$config.configuration.'system.webServer'.modules.add) {
            `$customSettings.Modules += @{
                Name = `$module.name
                Type = `$module.type
            }
        }
    }
    
    # Handlers
    if (`$config.configuration.'system.webServer'.handlers) {
        foreach (`$handler in `$config.configuration.'system.webServer'.handlers.add) {
            `$customSettings.Handlers += @{
                Name = `$handler.name
                Path = `$handler.path
                Verb = `$handler.verb
                Type = `$handler.type
                Modules = `$handler.modules
            }
        }
    }
    
    # Default documents
    if (`$config.configuration.'system.webServer'.defaultDocument) {
        foreach (`$doc in `$config.configuration.'system.webServer'.defaultDocument.files.add) {
            `$customSettings.DefaultDocument += `$doc.value
        }
    }
    
    # Directory browsing
    if (`$config.configuration.'system.webServer'.directoryBrowse) {
        `$customSettings.DirectoryBrowse.Enabled = `$config.configuration.'system.webServer'.directoryBrowse.enabled
    }
    
    # HTTP errors
    if (`$config.configuration.'system.webServer'.httpErrors) {
        foreach (`$error in `$config.configuration.'system.webServer'.httpErrors.error) {
            `$customSettings.HttpErrors += @{
                StatusCode = `$error.statusCode
                SubStatusCode = `$error.subStatusCode
                Path = `$error.path
                ResponseMode = `$error.responseMode
            }
        }
    }
    
    # HTTP logging
    if (`$config.configuration.'system.webServer'.httpLogging) {
        `$customSettings.HttpLogging = @{
            DontLog = `$config.configuration.'system.webServer'.httpLogging.dontLog
        }
    }
    
    # Request filtering
    if (`$config.configuration.'system.webServer'.security.requestFiltering) {
        `$customSettings.RequestFiltering = @{
            AllowDoubleEscaping = `$config.configuration.'system.webServer'.security.requestFiltering.allowDoubleEscaping
            MaxAllowedContentLength = `$config.configuration.'system.webServer'.security.requestFiltering.requestLimits.maxAllowedContentLength
        }
    }
    
    `$customSettings | ConvertTo-Json -Depth 10
} else {
    Write-Output "Config file not found"
}
"@

$configResult = Invoke-RemoteCommand -ScriptBlock $getConfigScript -Description "Get applicationHost.config"
if ($configResult -and $configResult -ne "Config file not found") {
    try {
        $script:IISConfig.CustomSettings = $configResult | ConvertFrom-Json
        Write-Log "Retrieved custom settings from applicationHost.config" "INFO"
    } catch {
        Write-Log "Error parsing config JSON: $($_.Exception.Message)" "ERROR"
    }
}

# Get SSL Certificates
Write-Log "Collecting SSL certificates..." "INFO"
$getCertificatesScript = @"
`$certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine")
`$certStore.Open("ReadOnly")
`$certificates = `$certStore.Certificates
`$certList = @()
foreach (`$cert in `$certificates) {
    `$certInfo = @{
        Thumbprint = `$cert.Thumbprint
        Subject = `$cert.Subject
        Issuer = `$cert.Issuer
        NotBefore = `$cert.NotBefore.ToString("yyyy-MM-dd HH:mm:ss")
        NotAfter = `$cert.NotAfter.ToString("yyyy-MM-dd HH:mm:ss")
        FriendlyName = `$cert.FriendlyName
        HasPrivateKey = `$cert.HasPrivateKey
    }
    `$certList += `$certInfo
}
`$certStore.Close()
`$certList | ConvertTo-Json -Depth 10
"@

$certsResult = Invoke-RemoteCommand -ScriptBlock $getCertificatesScript -Description "Get SSL certificates"
if ($certsResult) {
    try {
        $script:IISConfig.Certificates = $certsResult | ConvertFrom-Json
        Write-Log "Found $($script:IISConfig.Certificates.Count) certificates" "INFO"
    } catch {
        Write-Log "Error parsing certificates JSON: $($_.Exception.Message)" "ERROR"
    }
}

# Summary
Write-Log "========================================" "INFO"
Write-Log "IIS Configuration Scan Complete" "INFO"
Write-Log "Sites: $($script:IISConfig.Sites.Count)" "INFO"
Write-Log "Application Pools: $($script:IISConfig.ApplicationPools.Count)" "INFO"
Write-Log "Certificates: $($script:IISConfig.Certificates.Count)" "INFO"
Write-Log "Errors: $($script:IISConfig.Errors.Count)" "INFO"
Write-Log "========================================" "INFO"

# Save to cache
$cacheFileName = "$ServerName-IIS-config.json"
$cacheFilePath = Join-Path $CacheDir $cacheFileName

try {
    $script:IISConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $cacheFilePath
    Write-Log "Configuration saved to: $cacheFilePath" "INFO"
} catch {
    Write-Log "ERROR: Failed to save configuration: $($_.Exception.Message)" "ERROR"
}

Write-Host ""
Write-Host "IIS configuration inventory complete! Check:" -ForegroundColor Green
Write-Host "  Cache: $cacheFilePath" -ForegroundColor Cyan
Write-Host "  Log:   $script:LogFile" -ForegroundColor Cyan
Write-Host ""
