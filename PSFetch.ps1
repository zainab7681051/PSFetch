param (
[switch][alias("nc")]$NoLogoColor,
[switch][alias("m")]$MonoColor,
[string][alias("c")]$MyColor = "#FFFFFF",
[string[]][alias("cs")]$MyColors 
)

if (-not $iswindows) {
        write-host -foreground "Red" "PSFETCH IS ONLY SUPPORTED ON WINDOWS OPERTAING SYSTEM"
        exit 1
}

#OPERTAING SYSTEM
$os = Get-CimInstance Win32_OperatingSystem
$osName = $os.Caption
$osVersion = $os.Version

if ($osVersion -cnotlike "10.*") {
    write-host -foreground "Red" "PSFETCH IS ONLY SUPPORTED ON WINDOWS 10"
    exit 1
}

$psVersion = $PSVersionTable.PSVersion
if ($psVersion -lt [System.Version]"7.2"){
    write-host -foreground "Red" "PSFETCH IS ONLY SUPPORTED FOR POWERSHELL VERSION >= 7.2"
    exit 1
}

#HARDWARE
$computer = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model
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
    "OS: $osName [$osVersion]"
    "CPU: $($cpu.Name) [$(($cpu.MaxClockSpeed)/1000)GHz]"
    "GPU: $($gpu)"
    "Resolution: $($resolution)"
    "Memory [RAM]: {0:N1}GB / {1:N1}GB" -f $usedMemory, $totalMemory
    "Storage [C]: {0:N1}GB / {1:N1}GB" -f $usedStorage, $totalStorage
    "PowerShell: $psVersion"
    "Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
)

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

function Print-NoNewLine{
  param([string] $Text, [string] $Color)
  if($Color){
    return Write-Host -NoNewline "$($Color) $Text $($PSStyle.Reset)"
  }
  return Write-Host -NoNewline $Text
}

function Set-HexColor{
  param([string] $Hex)

  if([System.String]::IsNullOrEmpty($Hex)){
    Write-Host -Foreground "Red" "HEX VALUE FOR COLOR MUST BE PROVIDED."
    exit 1
  }

  switch($Hex[0]){
    "#" {
      $PSStyle.Foreground.FromRgb(($Hex -replace "#", "0x"))
    }
    "0"{
      if($Hex[1] -cne "x"){
        Write-Host -Foreground "Red" "MISSING 'x' SYMBOL AFTER '0' IN HEX COLOR: $Hex"
        exit 1
      }
      $PSStyle.Foreground.FromRgb($Hex)
    }
    default {
      Write-Host -Foreground "Red" "INCORRECT FORMAT FOR HEX COLOR: $Hex"
      Write-Host -NoNewline -Foreground "Red" "CORRECT FORMATS ARE: "
      Write-Host -Foreground "Yellow" "#<HEXADECIMAL-VALUE> or 0x<HEXADECIMAL-VALUE>"
      exit 1
    }
  }
}

function Print-MultiColors{
  param([string]$Line, [int]$Index, [string[]]$MColors)
  
  if($MColors.Length -lt 4){
      Write-Host -Foreground "Red" "MUST PROVIDE A SET OF 4 COLORS"
      exit 1
  }
  $colors = @{
    topLeft = Set-HexColor -Hex $MColors[0]   
    topRight = Set-HexColor -Hex $MColors[1]  
    bottomLeft = Set-HexColor -Hex $MColors[2] 
    bottomRight =Set-HexColor -Hex $MColors[3]
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

function Print-SingleColor{
  param([string]$Line, [string]$SingleColor)
  Print-NoNewLine -Text ($Line -replace "cc","  ") -Color (Set-HexColor -Hex $SingleColor)
}

function Print-NewLine{
  Write-Host ""
}

Print-NewLine
$info_indx = 0
for ($i=0; $i -lt $logo.Count; $i++) {

  if(-not $NoLogoColor) {
    if($MonoColor){
      Print-SingleColor -Line $logo[$i] -SingleColor $MyColor
    }
    else{
      if($MyColors){
        Print-MultiColors -Line $logo[$i] -Index $i -MColors $MyColors
      }
      else{
        $DefaultColors = "#D11141", "#00B159", "#24A2E9", "#FFC425"
        Print-MultiColors -Line $logo[$i] -Index $i -MColors $DefaultColors
      }
    }
  } 
  else{
    Print-SingleColor -Line $logo[$i] -SingleColor "#CCCCCC"
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

Print-NewLine
Print-NewLine
