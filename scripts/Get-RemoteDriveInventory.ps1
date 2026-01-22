#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Inventory remote Windows server drive via SMB or PowerShell Remoting.

.DESCRIPTION
    Connects to a remote server and recursively lists directories and files.
    Supports SMB (UNC path) or PowerShell Remoting for faster scans.
    Output saved to JSON cache and execution log.

.PARAMETER ServerName
    Target server name (e.g., EG-INTEGRATE-01, EG-WebApps-01)

.PARAMETER DriveLetter
    Drive letter to inventory (default: E)

.PARAMETER CacheDir
    Cache directory for output (default: .\cache)

.PARAMETER LogDir
    Log directory for execution logs (default: .\logs)

.PARAMETER MaxDepth
    Maximum directory depth to scan (default: 4)

.PARAMETER UseRemoting
    Use PowerShell Remoting (WinRM) instead of SMB

.PARAMETER IncludeFiles
    Include file listings in the inventory (default: true)

.EXAMPLE
    .\Get-RemoteDriveInventory.ps1 -ServerName "EG-INTEGRATE-01" -DriveLetter "E"

.EXAMPLE
    .\Get-RemoteDriveInventory.ps1 -ServerName "EG-WebApps-01" -DriveLetter "E"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ServerName,
    
    [Parameter(Mandatory=$false)]
    [string]$DriveLetter = "E",
    
    [Parameter(Mandatory=$false)]
    [string]$CacheDir = ".\cache",
    
    [Parameter(Mandatory=$false)]
    [string]$LogDir = ".\logs"
    ,
    [Parameter(Mandatory=$false)]
    [int]$MaxDepth = 4,
    
    [Parameter(Mandatory=$false)]
    [bool]$UseRemoting = $false,
    
    [Parameter(Mandatory=$false)]
    [bool]$IncludeFiles = $true
)

# Script configuration
$ErrorActionPreference = "Continue"
$script:LogFile = $null
$script:Inventory = @{
    ServerName = $ServerName
    DriveLetter = $DriveLetter
    ScanDate = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    RootPath = if ($UseRemoting) { "$DriveLetter`:\" } else { "\\$ServerName\$DriveLetter`$" }
    ServerRoot = "\\$ServerName\$DriveLetter`$"
    ScanMethod = if ($UseRemoting) { "Remoting" } else { "SMB" }
    MaxDepth = $MaxDepth
    IncludeFiles = $IncludeFiles
    Directories = @()
    Files = @()
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
$logFileName = "$ServerName-$DriveLetter`$-$timestamp.log"
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

function Get-RelativePath {
    param(
        [string]$FullPath,
        [string]$RootPath
    )

    if ($FullPath.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $FullPath.Substring($RootPath.Length)
    }

    return $FullPath
}

function Get-RemoteDirectoryListing {
    param(
        [string]$Path,
        [int]$Depth = 0,
        [int]$MaxDepth = 10
    )
    
    if ($Depth -gt $MaxDepth) {
        Write-Log "Max depth reached at: $Path" "WARN"
        return
    }
    
    try {
        # Test if path exists
        if (-not (Test-Path $Path)) {
            Write-Log "Path does not exist: $Path" "WARN"
            $script:Inventory.Errors += "Path not found: $Path"
            return
        }
        
        Write-Log "Scanning: $Path" "INFO"
        
        # Get directories
        $directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $directories) {
            $dirInfo = @{
                Name = $dir.Name
                FullPath = $dir.FullName
                RelativePath = Get-RelativePath -FullPath $dir.FullName -RootPath $script:Inventory.RootPath
                CreationTime = $dir.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                LastWriteTime = $dir.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                Depth = $Depth
            }
            
            $script:Inventory.Directories += $dirInfo
            
            # Recursively scan subdirectories
            Get-RemoteDirectoryListing -Path $dir.FullName -Depth ($Depth + 1) -MaxDepth $MaxDepth
        }
        
        if ($IncludeFiles) {
            # Get files
            $files = Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                $fileInfo = @{
                    Name = $file.Name
                    FullPath = $file.FullName
                    RelativePath = Get-RelativePath -FullPath $file.FullName -RootPath $script:Inventory.RootPath
                    Size = $file.Length
                    SizeKB = [math]::Round($file.Length / 1KB, 2)
                    SizeMB = [math]::Round($file.Length / 1MB, 2)
                    CreationTime = $file.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                    LastWriteTime = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                    Extension = $file.Extension
                    Depth = $Depth
                }
                
                $script:Inventory.Files += $fileInfo
            }
        }
        
    } catch {
        $errorMsg = "Error scanning $Path : $($_.Exception.Message)"
        Write-Log $errorMsg "ERROR"
        $script:Inventory.Errors += $errorMsg
    }
}

function Get-RemoteInventoryViaRemoting {
    param(
        [string]$TargetServer,
        [string]$TargetDrive,
        [int]$DepthLimit,
        [bool]$IncludeFileEntries
    )

    $scriptBlock = {
        param(
            [string]$DriveLetter,
            [int]$MaxDepth,
            [bool]$IncludeFiles
        )

        $rootPath = "$DriveLetter`:\"
        $result = [ordered]@{
            RootPath = $rootPath
            Directories = @()
            Files = @()
            Errors = @()
        }

        function Get-RelativePath {
            param(
                [string]$FullPath,
                [string]$RootPath
            )

            if ($FullPath.StartsWith($RootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
                return $FullPath.Substring($RootPath.Length)
            }

            return $FullPath
        }

        function Scan-Path {
            param(
                [string]$Path,
                [int]$Depth
            )

            if ($Depth -gt $MaxDepth) {
                return
            }

            try {
                if (-not (Test-Path $Path)) {
                    $result.Errors += "Path not found: $Path"
                    return
                }

                $directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue
                foreach ($dir in $directories) {
                    $result.Directories += [pscustomobject]@{
                        Name = $dir.Name
                        FullPath = $dir.FullName
                        RelativePath = Get-RelativePath -FullPath $dir.FullName -RootPath $rootPath
                        CreationTime = $dir.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                        LastWriteTime = $dir.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                        Depth = $Depth
                    }

                    Scan-Path -Path $dir.FullName -Depth ($Depth + 1)
                }

                if ($IncludeFiles) {
                    $files = Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
                    foreach ($file in $files) {
                        $result.Files += [pscustomobject]@{
                            Name = $file.Name
                            FullPath = $file.FullName
                            RelativePath = Get-RelativePath -FullPath $file.FullName -RootPath $rootPath
                            Size = $file.Length
                            SizeKB = [math]::Round($file.Length / 1KB, 2)
                            SizeMB = [math]::Round($file.Length / 1MB, 2)
                            CreationTime = $file.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")
                            LastWriteTime = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                            Extension = $file.Extension
                            Depth = $Depth
                        }
                    }
                }
            } catch {
                $result.Errors += "Error scanning $Path : $($_.Exception.Message)"
            }
        }

        if (-not (Test-Path $rootPath)) {
            $result.Errors += "Path not found: $rootPath"
            return $result
        }

        Scan-Path -Path $rootPath -Depth 0
        return $result
    }

    try {
        return Invoke-Command -ComputerName $TargetServer -ScriptBlock $scriptBlock -ArgumentList $TargetDrive, $DepthLimit, $IncludeFileEntries -ErrorAction Stop
    } catch {
        $errorMsg = "Remoting failed for $TargetServer : $($_.Exception.Message)"
        Write-Log $errorMsg "ERROR"
        $script:Inventory.Errors += $errorMsg
        return $null
    }
}

# Main execution
Write-Log "========================================" "INFO"
Write-Log "Remote Drive Inventory Script" "INFO"
Write-Log "Server: $ServerName" "INFO"
Write-Log "Drive: $DriveLetter" "INFO"
Write-Log "Root Path: $($script:Inventory.RootPath)" "INFO"
Write-Log "Scan Method: $($script:Inventory.ScanMethod)" "INFO"
Write-Log "Max Depth: $MaxDepth" "INFO"
Write-Log "Include Files: $([bool]$IncludeFiles)" "INFO"
Write-Log "========================================" "INFO"

# Test connectivity
Write-Log "Testing connectivity to $ServerName..." "INFO"
if (Test-Connection -ComputerName $ServerName -Count 1 -Quiet) {
    Write-Log "Server is reachable" "INFO"
} else {
    Write-Log "WARNING: Server may not be reachable" "WARN"
}

# Start inventory scan
Write-Log "Starting directory scan..." "INFO"
$startTime = Get-Date

if ($UseRemoting) {
    $remoteInventory = Get-RemoteInventoryViaRemoting -TargetServer $ServerName -TargetDrive $DriveLetter -DepthLimit $MaxDepth -IncludeFileEntries ([bool]$IncludeFiles)
    if ($null -ne $remoteInventory) {
        $script:Inventory.RootPath = $remoteInventory.RootPath
        $script:Inventory.Directories = $remoteInventory.Directories
        $script:Inventory.Files = $remoteInventory.Files
        $script:Inventory.Errors += $remoteInventory.Errors
    } else {
        Write-Log "Remoting inventory failed; no data collected." "ERROR"
    }
} else {
    # Test SMB connection
    Write-Log "Testing SMB connection to $($script:Inventory.RootPath)..." "INFO"
    $rootPath = $script:Inventory.RootPath

    try {
        if (Test-Path $rootPath) {
            Write-Log "SMB connection successful" "INFO"
        } else {
            Write-Log "ERROR: Cannot access $rootPath" "ERROR"
            Write-Log "Check permissions and network connectivity" "ERROR"
            exit 1
        }
    } catch {
        Write-Log "ERROR: SMB connection failed: $($_.Exception.Message)" "ERROR"
        exit 1
    }

    Get-RemoteDirectoryListing -Path $rootPath -MaxDepth $MaxDepth
}

$endTime = Get-Date
$duration = $endTime - $startTime

# Summary
Write-Log "========================================" "INFO"
Write-Log "Scan Complete" "INFO"
Write-Log "Directories found: $($script:Inventory.Directories.Count)" "INFO"
Write-Log "Files found: $($script:Inventory.Files.Count)" "INFO"
Write-Log "Errors: $($script:Inventory.Errors.Count)" "INFO"
Write-Log "Duration: $($duration.TotalSeconds) seconds" "INFO"
Write-Log "========================================" "INFO"

# Calculate total size
$totalSize = ($script:Inventory.Files | Measure-Object -Property Size -Sum).Sum
$script:Inventory.TotalSize = $totalSize
$script:Inventory.TotalSizeKB = [math]::Round($totalSize / 1KB, 2)
$script:Inventory.TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
$script:Inventory.TotalSizeGB = [math]::Round($totalSize / 1GB, 2)

Write-Log "Total size: $($script:Inventory.TotalSizeGB) GB" "INFO"

# Save to cache
$cacheFileName = "$ServerName-$DriveLetter`$-inventory.json"
$cacheFilePath = Join-Path $CacheDir $cacheFileName

try {
    $script:Inventory | ConvertTo-Json -Depth 10 | Set-Content -Path $cacheFilePath
    Write-Log "Inventory saved to: $cacheFilePath" "INFO"
} catch {
    Write-Log "ERROR: Failed to save inventory: $($_.Exception.Message)" "ERROR"
}

# Summary report
Write-Log "========================================" "INFO"
Write-Log "SUMMARY REPORT" "INFO"
Write-Log "========================================" "INFO"
Write-Log "Server: $ServerName" "INFO"
Write-Log "Drive: $DriveLetter" "INFO"
Write-Log "Directories: $($script:Inventory.Directories.Count)" "INFO"
Write-Log "Files: $($script:Inventory.Files.Count)" "INFO"
Write-Log "Total Size: $($script:Inventory.TotalSizeGB) GB" "INFO"
Write-Log "Errors: $($script:Inventory.Errors.Count)" "INFO"
Write-Log "Cache File: $cacheFilePath" "INFO"
Write-Log "Log File: $script:LogFile" "INFO"
Write-Log "========================================" "INFO"

Write-Host ""
Write-Host "Inventory complete! Check:" -ForegroundColor Green
Write-Host "  Cache: $cacheFilePath" -ForegroundColor Cyan
Write-Host "  Log:   $script:LogFile" -ForegroundColor Cyan
Write-Host ""
