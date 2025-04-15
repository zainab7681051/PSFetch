function Invoke-PSFetch {
$logo=@"
                          ....iilll
                 ....iilllllllllllllN
     ....iillll  lllllllllllllllllllN
 iillllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
                                    N
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 llllllllllllll  lllllllllllllllllllN
 ''llllllllllll  lllllllllllllllllllN
       ''''llll  ''lllllllllllllllllN
                      ''''''^^^^llllN
"@ -split "N"

    #HARDWARE
    $computer = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model
    #OPERTAING SYSTEM
    $os = Get-CimInstance Win32_OperatingSystem
    #CPU
    $cpu = Get-CimInstance Win32_Processor
    $cpuClockSpeed = ($cpu.MaxClockSpeed)/1000 
    #MEMORY [RAM]
    $memory = Get-CimInstance Win32_PhysicalMemory
    $totalMemory = ($memory | Measure-Object -Property Capacity -Sum).Sum / 1GB
    $freeMemory = $os.FreePhysicalMemory / 1MB
    $usedMemory = $totalMemory - $freeMemory
    #STORAGE [C DRIVE]
    $storage = Get-Volume | Where-Object DriveLetter -ceq "C" | Select-Object DriveLetter, SizeRemaining, Size
    $freeStorage = ($storage.SizeRemaining)/1GB
    $totalStorage = ($storage.size)/1GB
    $usedStorage = $totalStorage - $freeStorage
    #additional
    $uptime = (Get-Date) - $os.LastBootUpTime

    $info = @(
        "PC: $($computer.Manufacturer) [$($computer.Model)]"
        "OS: $($os.Caption) [$($os.Version)]"
        "Hostname: $($env:COMPUTERNAME)"
        "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
        "CPU: $($cpu.Name) [$($cpuClockSpeed)GHz]"
        "Memory [RAM]: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
        "Storage [C]: {0:N1}GB / {1:N1}GB" -f $usedStorage, $totalStorage
        "PowerShell: $($PSVersionTable.PSVersion)"
    )

    $color = "Blue"
    $line_num = 0
    foreach ($line in $logo) {
      Write-Host -NoNewline -ForegroundColor $color $line
      if($line_num -lt $info.Count){
        Write-Host -NoNewline ((" " * 3) + ($info[$line_num++])) 
      }     
    }
}

# Invoke-PSFetch

<#if (($Host.Name -eq 'ConsoleHost' -or $Host.Name -like '*Terminal*') -and -not [System.Console]::IsOutputRedirected) {
    Invoke-PSFetch
}#>
