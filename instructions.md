# PSSysTray
 
## Description
Creates a System Tray Menu from a csv file to launch any PowerShell Command or file (or any other executable)
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/PSSysTray)
```
Install-Module -Name PSSysTray -Verbose
```
- or from GitHub [GitHub Repo](https://github.com/smitpi/PSSysTray)
```
git clone https://github.com/smitpi/PSSysTray (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath PSSysTray)
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
