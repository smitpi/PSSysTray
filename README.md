# PSSysTray
 
## Description
Creates a System Tray Menu from a csv file to launch any PowerShell Command or file (or any other executable)
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSSysTray)
```
Install-Module -Name PSSysTray -Verbose
```
- or run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/PSSysTray)
```
$CurrentLocation = Get-Item .
$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSSysTray)
git clone --depth 1 https://github.com/smitpi/PSSysTray $ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $ModuleDestination
git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $CurrentLocation
```
- Then import the module into your session
```
Import-Module PSSysTray -Verbose -Force
```
- or run these commands for more help and details.
```
Get-Command -Module PSSysTray
Get-Help about_PSSysTray
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/PSSysTray)
 
## Functions
- [`Edit-PSSysTrayConfig`](https://smitpi.github.io/PSSysTray/Edit-PSSysTrayConfig) -- Edit the config File
- [`New-PSSysTrayConfigFile`](https://smitpi.github.io/PSSysTray/New-PSSysTrayConfigFile) -- Creates the needed .csv file in the specified folder.
- [`Start-PSSysTray`](https://smitpi.github.io/PSSysTray/Start-PSSysTray) -- This function reads csv config file and creates the GUI in your system tray.
