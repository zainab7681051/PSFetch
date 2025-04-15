function Invoke-PSFetch {
    $logo = @"
      .___...---;;---...___
'-..-'|         ||         |n
'-..-'|         ||         |n
'-..-'|         ||         |n
'-..-'|         ||         |n
'-..-'|___...---;;---...___|n
'-..-'|         ||         |n
'-..-'|         ||         |n
'-..-'|         ||         |n
'-..-'|         ||         |n
'-..-'|___...---''---...___|n
"@ -split "n"

    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $cpuClockSpeed = ($cpu.MaxClockSpeed)/1000 
    $memory = Get-CimInstance Win32_PhysicalMemory
    $totalMemory = ($memory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $osMemory = Get-CimInstance Win32_OperatingSystem
    $freeMemory = $osMemory.FreePhysicalMemory / 1MB
    $usedMemory = $totalMemory - $freeMemory
    $storage = Get-Volume | Where-Object DriveLetter -ceq "C" | Select-Object DriveLetter, SizeRemaining, Size
    $freeStorage = ($storage.SizeRemaining)/1GB
    $totalStorage = ($storage.size)/1GB
    $usedStorage = $totalStorage - $freeStorage
    $uptime = (Get-Date) - $os.LastBootUpTime

    $info = @(
        "OS: $($os.Caption) [$($os.Version)]"
        "Hostname: $($env:COMPUTERNAME)"
        "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
        "CPU: $($cpu.Name) [$($cpuClockSpeed)GHz]"
        "Memory [RAM]: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
        "Storage [C:\]: {0:N1}GB / {1:N1}GB" -f $usedStorage, $totalStorage
        "PowerShell: $($PSVersionTable.PSVersion)"
    )

    $color = "Blue"
    $info_index=0
    foreach ($line in $logo) {
      Write-Host -NoNewline -ForegroundColor $color $line
      if($info_index -lt $info.Count){
        Write-Host -NoNewline ((" " * 3) + ($info[$info_index++])) 
      }     
    }
}

# Invoke-PSFetch

<#if (($Host.Name -eq 'ConsoleHost' -or $Host.Name -like '*Terminal*') -and -not [System.Console]::IsOutputRedirected) {
    Invoke-PSFetch
}#>
