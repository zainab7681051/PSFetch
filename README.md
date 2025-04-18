# PSFetch

> A basic PowerShell system information fetcher for Windows 10 and PowerShell 7.2+

- [Prerequisites](#prerequisites)  
- [Installation](#installation)  
- [Usage](#usage)  

## Prerequisites

- **Operating System:** Windows 10 
- **PowerShell Version:** PowerShell 7.2 or higher  

## Installation

1. clone the repository
  ```powershell
    git clone "https://github.com/zainab7681051/PSFetch"
  ```
2. Run the script
  ```powershell
    set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Scope CurrentUser
    .\PSfetch.ps1
  ```

## Usage
```powershell
    # Default: colored logo + system info
    PSFetch.ps1
    
    # No logo coloring
    PSFetch.ps1 -NoLogoColor
    
    # Mono‑color logo (default white)
    PSFetch.ps1 -MonoColor -MyColor '#00FF00'
    
    # Gradient logo with four hex colors
    PSFetch.ps1 -MyColors '#FF0000','#00FF00','#0000FF','#FFFF00'
```
