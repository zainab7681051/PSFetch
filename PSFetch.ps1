function Invoke-PSFetch {

  function Print-NoNewLine{
    param($Text, $Color)
    if($Color){
      return Write-Host -NoNewline "$($Color) $Text $($PSStyle.Reset)"
    }
    return Write-Host -NoNewline $Text
  }

  $logo=@"
               cc        ....iiilllN
               cc....iilllllllllllllN
     ....iillllcclllllllllllllllllllN
 iillllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
               cc                   N
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 llllllllllllllcclllllllllllllllllllN
 ''llllllllllllcclllllllllllllllllllN
       ''''llllcc''lllllllllllllllllN
               cc     ''''''^^^^llllN
"@ -split "N"

    #HARDWARE
    $computer = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model
    #OPERTAING SYSTEM
    $os = Get-CimInstance Win32_OperatingSystem
    #CPU
    $cpu = Get-CimInstance Win32_Processor | Select-Object Name, MaxClockSpeed
    #GRAPHICS CARD
    $videoController = Get-CimInstance Win32_VideoController | Select-Object Caption, CurrentHorizontalResolution, CurrentVerticalResolution
    $gCard = $videoController.Caption
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
    #ADDITIONAL
    $resolution = "$($videoController.CurrentHorizontalResolution) x $($videoController.CurrentVerticalResolution)"
    $uptime = (Get-Date) - $os.LastBootUpTime

    $info = @(
        "PC: $($computer.Manufacturer) [$($computer.Model)]"
        "OS: $($os.Caption) [$($os.Version)]"
        "Hostname: $($env:COMPUTERNAME)"
        "CPU: $($cpu.Name) [$(($cpu.MaxClockSpeed)/1000)GHz]"
        "Grahics card: $($gCard)"
        "Resolution: $($resolution)"
        "Memory [RAM]: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
        "Storage [C]: {0:N1}GB / {1:N1}GB" -f $usedStorage, $totalStorage
        "PowerShell: $($PSVersionTable.PSVersion)"
        "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
    )

    $colors = @{
      blue = $PSStyle.Foreground.FromRgb(0x00aedb) 
      green = $PSStyle.Foreground.FromRgb(0x00b159)
      yellow = $PSStyle.Foreground.FromRgb(0xffc425) 
      red = $PSStyle.Foreground.FromRgb(0xd11141) 
    } 

    $info_indx = 0
    $line_indx = 0
    foreach ($line in $logo) {
      $lineParts = $line -split "cc", 2

      if(($line_indx++) -ge ($logo.Count)/2){
        Print-NoNewLine -Text $lineParts[0] -Color $colors.blue
        Print-NoNewLine -Text $lineParts[1] -Color $colors.yellow
      }
      else {
        Print-NoNewLine -Text $lineParts[0] -Color $colors.red 
        Print-NoNewLine -Text $lineParts[1] -Color $colors.green
      }

      if($info_indx -lt $info.Count){
        $text = $info[$info_indx++]
        $parts = $text -split ":", 2
        $label = $parts[0] + ":"
        $value = $parts[1] 

        Print-NoNewLine -Text $label -Color $colors.blue
        Print-NoNewLine -Text $value
      }     
    }
}

# Invoke-PSFetch

<#if (($Host.Name -eq 'ConsoleHost' -or $Host.Name -like '*Terminal*') -and -not [System.Console]::IsOutputRedirected) {
    Invoke-PSFetch
}#>
