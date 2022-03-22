
<#PSScriptInfo

.VERSION 0.1.0

.GUID 9687de4d-6ef6-4383-8fd9-7ba8647bf090

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [22/03/2022_11:40] Initial Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 This function reads csv config file and creates the gui in your system tray. 

#> 


<#
.SYNOPSIS
This function reads csv config file and creates the gui in your system tray.

.DESCRIPTION
This function reads csv config file and creates the gui in your system tray.

.EXAMPLE
Start-PSSysTray

#>
Function Start-PSSysTray {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSSysTray/Start-PSSysTray")]
		PARAM()
}