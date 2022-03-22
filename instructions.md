# XDHealthCheck
 
## Description
Creates daily health check and config reports for your on-premise Citrix farm. To get started, you need to run Install-ParametersFile.
This will capture and save needed farm details, to allow scripts to run automatically.
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/XDHealthCheck)
```powershell=
Install-Module -Name XDHealthCheck -Verbose
```
- or from GitHub [GitHub Repo](https://github.com/smitpi/XDHealthCheck)
```powershell=
git clone https://github.com/smitpi/XDHealthCheck (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath XDHealthCheck)
```
- Then import the module into your session
```powershell=
Import-Module XDHealthCheck -Verbose -Force
```
- or run these commands for more help and details.
```powershell=
Get-Command -Module XDHealthCheck
Get-Help about_XDHealthCheck
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/XDHealthCheck)
