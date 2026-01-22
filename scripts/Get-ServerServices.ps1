#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Inventory Windows services and scheduled tasks from remote server.

.DESCRIPTION
    Connects to remote server via WinRM and exports Windows services and
    scheduled tasks configuration. Output saved to JSON cache and execution log.

.PARAMETER ServerName
    Target server name (e.g., EG-INTEGRATE-01, EG-WebApps-01)

.PARAMETER CacheDir
    Cache directory for output (default: .\cache)

.PARAMETER LogDir
    Log directory for execution logs (default: .\logs)

.EXAMPLE
    .\Get-ServerServices.ps1 -ServerName "EG-INTEGRATE-01"
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
$script:ServicesConfig = @{
    ServerName = $ServerName
    ScanDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Services = @()
    ScheduledTasks = @()
    Errors = @()
}

# Ensure cache and log directories exist
if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
}

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Initialize log file
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFileName = "$ServerName-Services-$timestamp.log"
$script:LogFile = Join-Path $LogDir $logFileName

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$Level] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        "INFO"  { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
    
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
        $script:ServicesConfig.Errors += $errorMsg
        return $null
    }
}

# Main execution
Write-Log "========================================" "INFO"
Write-Log "Windows Services & Scheduled Tasks Inventory" "INFO"
Write-Log "Server: $ServerName" "INFO"
Write-Log "========================================" "INFO"

# Test connectivity
if (-not (Test-Connection -ComputerName $ServerName -Count 1 -Quiet)) {
    Write-Log "WARNING: Server may not be reachable" "WARN"
}

# Test WinRM
try {
    $testWinRM = Invoke-Command -ComputerName $ServerName -ScriptBlock { $true } -ErrorAction Stop
    if ($testWinRM) {
        Write-Log "WinRM connection successful" "INFO"
    }
} catch {
    Write-Log "ERROR: WinRM connection failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Get Windows Services
Write-Log "Collecting Windows services..." "INFO"
$getServicesScript = @"
`$services = Get-Service
`$serviceList = @()
foreach (`$svc in `$services) {
    `$svcInfo = @{
        Name = `$svc.Name
        DisplayName = `$svc.DisplayName
        Status = `$svc.Status.ToString()
        StartType = `$svc.StartType.ToString()
    }
    
    # Get service details
    `$svcDetails = Get-CimInstance -ClassName Win32_Service -Filter "Name='`$(`$svc.Name)'"
    if (`$svcDetails) {
        `$svcInfo.PathName = `$svcDetails.PathName
        `$svcInfo.Description = `$svcDetails.Description
        `$svcInfo.ServiceAccount = `$svcDetails.StartName
        `$svcInfo.ProcessId = `$svcDetails.ProcessId
    }
    
    `$serviceList += `$svcInfo
}
`$serviceList | ConvertTo-Json -Depth 10
"@

$servicesResult = Invoke-RemoteCommand -ScriptBlock $getServicesScript -Description "Get Windows services"
if ($servicesResult) {
    try {
        $script:ServicesConfig.Services = $servicesResult | ConvertFrom-Json
        Write-Log "Found $($script:ServicesConfig.Services.Count) Windows services" "INFO"
    } catch {
        Write-Log "Error parsing services JSON: $($_.Exception.Message)" "ERROR"
    }
}

# Get Scheduled Tasks
Write-Log "Collecting scheduled tasks..." "INFO"
$getTasksScript = @"
`$tasks = Get-ScheduledTask
`$taskList = @()
foreach (`$task in `$tasks) {
    `$taskInfo = @{
        TaskName = `$task.TaskName
        TaskPath = `$task.TaskPath
        State = `$task.State.ToString()
    }
    
    # Get task details
    `$taskDetails = Get-ScheduledTaskInfo -TaskName `$task.TaskName -TaskPath `$task.TaskPath -ErrorAction SilentlyContinue
    if (`$taskDetails) {
        `$taskInfo.LastRunTime = `$taskDetails.LastRunTime.ToString("yyyy-MM-dd HH:mm:ss")
        `$taskInfo.NextRunTime = `$taskDetails.NextRunTime.ToString("yyyy-MM-dd HH:mm:ss")
        `$taskInfo.LastTaskResult = `$taskDetails.LastTaskResult
    }
    
    # Get task actions
    `$taskActions = `$task.Actions
    `$taskInfo.Actions = @()
    foreach (`$action in `$taskActions) {
        `$taskInfo.Actions += @{
            Execute = `$action.Execute
            Arguments = `$action.Arguments
            WorkingDirectory = `$action.WorkingDirectory
        }
    }
    
    # Get task triggers
    `$taskTriggers = `$task.Triggers
    `$taskInfo.Triggers = @()
    foreach (`$trigger in `$taskTriggers) {
        `$taskInfo.Triggers += @{
            Enabled = `$trigger.Enabled
            StartBoundary = `$trigger.StartBoundary.ToString("yyyy-MM-dd HH:mm:ss")
            Repetition = @{
                Interval = `$trigger.Repetition.Interval
                Duration = `$trigger.Repetition.Duration
            }
        }
    }
    
    `$taskList += `$taskInfo
}
`$taskList | ConvertTo-Json -Depth 10
"@

$tasksResult = Invoke-RemoteCommand -ScriptBlock $getTasksScript -Description "Get scheduled tasks"
if ($tasksResult) {
    try {
        $script:ServicesConfig.ScheduledTasks = $tasksResult | ConvertFrom-Json
        Write-Log "Found $($script:ServicesConfig.ScheduledTasks.Count) scheduled tasks" "INFO"
    } catch {
        Write-Log "Error parsing tasks JSON: $($_.Exception.Message)" "ERROR"
    }
}

# Summary
Write-Log "========================================" "INFO"
Write-Log "Services & Tasks Scan Complete" "INFO"
Write-Log "Services: $($script:ServicesConfig.Services.Count)" "INFO"
Write-Log "Scheduled Tasks: $($script:ServicesConfig.ScheduledTasks.Count)" "INFO"
Write-Log "Errors: $($script:ServicesConfig.Errors.Count)" "INFO"
Write-Log "========================================" "INFO"

# Save to cache
$cacheFileName = "$ServerName-Services-config.json"
$cacheFilePath = Join-Path $CacheDir $cacheFileName

try {
    $script:ServicesConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $cacheFilePath
    Write-Log "Configuration saved to: $cacheFilePath" "INFO"
} catch {
    Write-Log "ERROR: Failed to save configuration: $($_.Exception.Message)" "ERROR"
}

Write-Host ""
Write-Host "Services inventory complete! Check:" -ForegroundColor Green
Write-Host "  Cache: $cacheFilePath" -ForegroundColor Cyan
Write-Host "  Log:   $script:LogFile" -ForegroundColor Cyan
Write-Host ""
