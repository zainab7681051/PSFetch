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

"@ -split ""

    # System Information
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $memory = Get-CimInstance Win32_PhysicalMemory
    $totalMemory = ($memory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $osMemory = Get-CimInstance Win32_OperatingSystem
    $freeMemory = $osMemory.FreePhysicalMemory / 1MB
    $usedMemory = $totalMemory - $freeMemory
    $uptime = (Get-Date) - $os.LastBootUpTime

    $info = @(
        "OS: $($os.Caption) [$($os.Version)]"
        "Hostname: $($env:COMPUTERNAME)"
        "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
        "CPU: $($cpu.Name)"
        "Memory: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
        "PowerShell: $($PSVersionTable.PSVersion)"
    )

    # Display logo and info
    $color = "Blue"
    $info_index=0
    foreach ($char in $logo) {
      if(-not($char -ceq "n")){
        Write-Host -NoNewline -ForegroundColor $color $char
      }
      else{
        if($info_index -lt $info.Count){
          Write-Host -NoNewline ((" " * 3) + ($info[$info_index++])) 
        }
      }     
    }
}

Invoke-PSFetch

<#if (($Host.Name -eq 'ConsoleHost' -or $Host.Name -like '*Terminal*') -and -not [System.Console]::IsOutputRedirected) {
    Invoke-PSFetch
}#>
