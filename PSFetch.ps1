function Start-PSFetch {
  param ([switch][alias("nc")]$NoLogoColor)

  if (-not ($IsWindows -or $PSVersionTable.PSVersion.Major -eq 5)) {
      Write-Error "Only supported on Windows with PowerShell version >= 5"
      exit 1
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
    $gpu = $videoController.Caption
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
        "Hostname: $($env:COMPUTERNAME)"
        "PC: $($computer.Manufacturer) [$($computer.Model)]"
        "OS: $($os.Caption) [$($os.Version)]"
        "CPU: $($cpu.Name) [$(($cpu.MaxClockSpeed)/1000)GHz]"
        "GPU: $($gpu)"
        "Resolution: $($resolution)"
        "Memory [RAM]: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
        "Storage [C]: {0:N1}GB / {1:N1}GB" -f $usedStorage, $totalStorage
        "PowerShell: $($PSVersionTable.PSVersion)"
        "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
    )

    function Print-NoNewLine{
      param([string] $Text, [string] $Color)
      if($Color){
        return Write-Host -NoNewline "$($Color) $Text $($PSStyle.Reset)"
      }
      return Write-Host -NoNewline $Text
    }

    function Set-HexColor{
      param([string] $Hex)
      if($Hex){
        $PSStyle.Foreground.FromRgb(($Hex -replace "#", "0x"))
      }
    }

    function Print-ColoredLogo{
      param([string] $Line, [int] $Index)

      $colors = @{
        topLeft = Set-HexColor -Hex "#D11141"
        topRight = Set-HexColor -Hex "#00B159"
        bottomLeft = Set-HexColor -Hex "#00AEDB"
        bottomRight =Set-HexColor -Hex "#FFC425"
      }

      $LineParts = $Line -split "cc", 2
  
      if($Index -ge ($logo.Count)/2){
        Print-NoNewLine -Text $LineParts[0] -Color $colors.bottomLeft
        Print-NoNewLine -Text $LineParts[1] -Color $colors.bottomRight
      }
      else {
        Print-NoNewLine -Text $LineParts[0] -Color $colors.topLeft 
        Print-NoNewLine -Text $LineParts[1] -Color $colors.topRight
      }
    }

    function Print-ColorelessLogo{
      param([string] $Line)
      Print-NoNewLine -Text ($Line -replace "cc","  ") -Color (Set-HexColor -Hex "#FFFFFF")
    }

    $info_indx = 0
    for ($i=0; $i -lt $logo.Count; $i++) {
      if(-not $NoLogoColor) {
        Print-ColoredLogo -Line $logo[$i] -Index $i
      } 
      else{
        Print-ColorelessLogo -Line $logo[$i]
      }

      if($info_indx -lt $info.Count){
        $text = $info[$info_indx++]
        $parts = $text -split ":", 2
        $label = $parts[0] + ":"
        $value = $parts[1] 

        Print-NoNewLine -Text $label -Color (Set-HexColor -Hex "#00FFFF")
        Print-NoNewLine -Text $value
      }     
    }
}
