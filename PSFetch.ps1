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
    $cpu = Get-CimInstance Win32_Processor | Select-Object Name, MaxClockSpeed
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
        "CPU: $($cpu.Name) [$(($cpu.MaxClockSpeed)/1000)GHz]"
        "Memory [RAM]: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
        "Storage [C]: {0:N1}GB / {1:N1}GB" -f $usedStorage, $totalStorage
        "PowerShell: $($PSVersionTable.PSVersion)"
    )

    $colors = @{
      blue = "Blue"
      pink = $PSStyle.Foreground.FromRgb(0xFF0054)
    } 

    $line_num = 0
    foreach ($line in $logo) {
      Write-Host -NoNewline -ForegroundColor $colors.blue $line
      if($line_num -lt $info.Count){
        $text = $info[$line_num++]
        $parts = $text -split ":", 2
        $label = $parts[0] + ":"
        $value = $parts[1] 
        Write-Host -NoNewline (" " * 3)
        Write-Host -NoNewline "$($colors.pink) $label $($PSStyle.Reset)"
        Write-Host -NoNewline $value
      }     
    }
}

# Invoke-PSFetch

<#if (($Host.Name -eq 'ConsoleHost' -or $Host.Name -like '*Terminal*') -and -not [System.Console]::IsOutputRedirected) {
    Invoke-PSFetch
}#>
