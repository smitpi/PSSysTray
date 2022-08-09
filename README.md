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
 
## Functions
- [`Add-PSSysTrayEntry`](https://smitpi.github.io/PSSysTray/Add-PSSysTrayEntry) -- Add an entry in the csv config file.
- [`Edit-PSSysTrayConfig`](https://smitpi.github.io/PSSysTray/Edit-PSSysTrayConfig) -- Edit the config File
- [`New-PSSysTrayConfigFile`](https://smitpi.github.io/PSSysTray/New-PSSysTrayConfigFile) -- Creates the needed .csv file in the specified folder.
- [`Start-PSSysTray`](https://smitpi.github.io/PSSysTray/Start-PSSysTray) -- This function reads csv config file and creates the GUI in your system tray.
