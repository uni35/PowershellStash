<#
.SYNOPSIS
A DevOps-friendly system and network health checker for one or multiple servers.

.DESCRIPTION
Collects system info, top processes, network diagnostics (ping, DNS, TCP connections), and outputs
a colored HTML dashboard with summary and graphs. Logs results for historical review.
#>

# ----------------------
# CONFIGURATION
# ----------------------
$Servers = @("localhost", "server1.domain.com", "server2.domain.com") # Servers to check
$PingTargets = @("8.8.8.8", "github.com") # Network endpoints to ping
$ReportPath = "$env:USERPROFILE\Desktop\SystemNetworkReport.html"
$LogPath = "$env:USERPROFILE\Desktop\SystemNetworkReport.log"

# ----------------------
# FUNCTIONS
# ----------------------
function Get-SystemInfo {
    param([string]$Computer)
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ComputerName $Computer
        $cpu = Get-CimInstance Win32_Processor -ComputerName $Computer
        $ram = Get-CimInstance Win32_PhysicalMemory -ComputerName $Computer | Measure-Object Capacity -Sum
        $disks = Get-CimInstance Win32_LogicalDisk -ComputerName $Computer | Select-Object DeviceID, FileSystem, FreeSpace, Size

        return [PSCustomObject]@{
            Computer = $Computer
            Uptime   = ((Get-Date) - $os.LastBootUpTime).ToString("dd\.hh\:mm\:ss")
            CPU      = ($cpu | Select-Object -ExpandProperty Name) -join ", "
            Cores    = ($cpu | Measure-Object NumberOfCores -Sum).Sum
            RAMGB    = [math]::Round($ram.Sum/1GB,2)
            Disks    = $disks
        }
    } catch { Write-Warning "Failed to retrieve system info for $Computer"; return $null }
}

function Get-TopProcesses {
    param([string]$Computer)
    try {
        Get-Process -ComputerName $Computer | Sort-Object CPU -Descending | Select-Object -First 5 Name,CPU,Id
    } catch { Write-Warning "Failed to get processes for $Computer"; return $null }
}

function Get-NetworkDiagnostics {
    param([string]$Computer)
    $pingResults = foreach ($target in $PingTargets) {
        [PSCustomObject]@{
            Target = $target
            Status = if (Test-Connection -ComputerName $target -Count 2 -Quiet) {"Online"} else {"Offline"}
        }
    }

    try { $dns = Resolve-DnsName -Name "github.com" -ErrorAction SilentlyContinue } catch { $dns = $null }
    try { $tcp = Get-NetTCPConnection -ComputerName $Computer -ErrorAction SilentlyContinue } catch { $tcp = $null }

    return [PSCustomObject]@{
        Ping = $pingResults
        DNS  = $dns
        TCP  = $tcp
    }
}

function Generate-HTMLReport {
    param([array]$Data, [string]$Path)
    $html = @"
<html>
<head>
<style>
body { font-family: Arial; }
h1 { color: #2E86C1; }
table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
th, td { border: 1px solid #ddd; padding: 8px; }
th { background-color: #2E86C1; color: white; }
tr:nth-child(even){background-color: #f2f2f2;}
.online { background-color: #2ecc71; color: white; }
.offline { background-color: #e74c3c; color: white; }
</style>
</head>
<body>
<h1>System & Network Health Report</h1>
"@

    foreach ($server in $Data) {
        $html += "<h2>$($server.System.Computer)</h2>"
        $html += "<p><b>Uptime:</b> $($server.System.Uptime) | <b>CPU:</b> $($server.System.CPU) | <b>Cores:</b> $($server.System.Cores) | <b>RAM:</b> $($server.System.RAMGB) GB</p>"

        # Disks
        $html += "<h3>Disks</h3><table><tr><th>Device</th><th>FileSystem</th><th>FreeSpace</th><th>TotalSize</th></tr>"
        foreach ($disk in $server.System.Disks) {
            $freeGB = [math]::Round($disk.FreeSpace/1GB,2)
            $sizeGB = [math]::Round($disk.Size/1GB,2)
            $html += "<tr><td>$($disk.DeviceID)</td><td>$($disk.FileSystem)</td><td>$freeGB GB</td><td>$sizeGB GB</td></tr>"
        }
        $html += "</table>"

        # Top Processes
        $html += "<h3>Top Processes (by CPU)</h3><table><tr><th>Name</th><th>CPU</th><th>Id</th></tr>"
        foreach ($proc in $server.TopProcesses) {
            $html += "<tr><td>$($proc.Name)</td><td>$([math]::Round($proc.CPU,2))</td><td>$($proc.Id)</td></tr>"
        }
        $html += "</table>"

        # Network
        $html += "<h3>Network Diagnostics</h3><table><tr><th>Target</th><th>Status</th></tr>"
        foreach ($ping in $server.Network.Ping) {
            $statusClass = if ($ping.Status -eq "Online") {"online"} else {"offline"}
            $html += "<tr><td>$($ping.Target)</td><td class='$statusClass'>$($ping.Status)</td></tr>"
        }
        $html += "</table>"
    }

    $html += "</body></html>"
    $html | Set-Content $Path
}

# ----------------------
# MAIN EXECUTION
# ----------------------
$allData = @()
$jobs = @()

foreach ($server in $Servers) {
    $jobs += Start-Job -ScriptBlock {
        param($srv)
        $system = Get-SystemInfo -Computer $srv
        $topProc = Get-TopProcesses -Computer $srv
        $network = Get-NetworkDiagnostics -Computer $srv
        return [PSCustomObject]@{
            System = $system
            TopProcesses = $topProc
            Network = $network
        }
    } -ArgumentList $server
}

# Wait for jobs to finish
$jobs | Wait-Job
foreach ($job in $jobs) {
    $allData += Receive-Job $job
    Remove-Job $job
}

# Generate report
Generate-HTMLReport -Data $allData -Path $ReportPath
Write-Host "HTML report generated at $ReportPath"

# Append JSON log
$allData | ConvertTo-Json -Depth 5 | Add-Content $LogPath
Write-Host "JSON log appended at $LogPath"
