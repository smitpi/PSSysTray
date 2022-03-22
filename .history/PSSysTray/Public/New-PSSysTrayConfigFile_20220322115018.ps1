
<#PSScriptInfo

.VERSION 0.1.0

.GUID 9ff9b47f-9cba-4e4a-8b5b-6d7e0acd1670

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS csv

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [22/03/2022_11:39] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
Creates the needed .csv file in the specified folder.

#>

<#
.SYNOPSIS
Creates the needed .csv file in the specified folder.

.DESCRIPTION
Creates the needed .csv file in the specified folder.

.PARAMETER ConfigPath
Path to where the config file will be saved.

.PARAMETER CreateShortcut
Create a shortcut to a .ps1 file that will launch the gui.

.EXAMPLE
New-PSSysTrayConfigFile -ConfigPath C:\temp -CreateShortcut

#>
Function New-PSSysTrayConfigFile {
	[Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSSysTray/New-PSSysTrayConfigFile')]
	PARAM(
		[ValidateScript( { (Test-Path $_) })]
		[System.IO.DirectoryInfo]$ConfigPath,
		[switch]$CreateShortcut = $false
	)


	[System.Collections.ArrayList]$Export = @()
	$export += [PSCustomObject]@{
		MainMenu   = 'Level1'
		ScriptName = 'TempScript'
		ScriptPath = 'C:\temp\script.ps1'
		Mode       = 'PSFile'
	}
	$export += [PSCustomObject]@{
		MainMenu   = 'Level2'
		ScriptName = 'Command'
		ScriptPath = 'get-command'
		Mode       = 'PSCommand'
	}
	$export += [PSCustomObject]@{
		MainMenu   = 'Level3'
		ScriptName = 'Restart'
		ScriptPath = 'shutdown /f /r /t 0'
		Mode       = 'Other'
	}

	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

		$Configfile = (Join-Path $ConfigPath -ChildPath \PSSysTrayConfig.csv)
		$check = Test-Path -Path $Configfile -ErrorAction SilentlyContinue
		if (-not($check)) {
			Write-Output 'Config File does not exit, creating default settings.'
			$export | Export-Csv -Path $Configfile -NoClobber -NoTypeInformation
		} else {
			Write-Warning 'File exists, renaming file now'
			Rename-Item $Configfile -NewName "PSSysTrayConfig_$(Get-Date -Format ddMMyyyy_HHmm).csv"
			$export | Export-Csv -Path $Configfile -NoClobber -NoTypeInformation
		}

		if ($CreateShortcut) {
			$module = Get-Module PSSysTray
			if (![bool]$module) { $module = Get-Module PSSysTray -ListAvailable }

			$string = @"
`$PRModule = Get-ChildItem `"$((Join-Path ((Get-Item $module.ModuleBase).Parent).FullName "\*\$($module.name).psm1"))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
import-module `$PRModule.fullname -Force
Start-PSSysTray -ConfigFilePath $((Join-Path $ConfigPath -ChildPath \PSSysTrayConfig.csv -Resolve))
"@
			Set-Content -Value $string -Path (Join-Path $ConfigPath -ChildPath \PSSysTray.ps1) | Get-Item
			$PSSysTray = (Join-Path $ConfigPath -ChildPath \PSSysTray.ps1) | Get-Item

			$WScriptShell = New-Object -ComObject WScript.Shell
			$lnkfile = ($PSSysTray.FullName).Replace('ps1', 'lnk')
			$Shortcut = $WScriptShell.CreateShortcut($($lnkfile))
			$Shortcut.TargetPath = 'powershell.exe'
			$Shortcut.Arguments = "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -file `"$($PSSysTray.FullName)`""
			$icon = Get-Item (Join-Path $module.ModuleBase .\Private\PSSysTray.ico)
			$Shortcut.IconLocation = $icon.FullName
			$Shortcut.Save()
			Start-Process explorer.exe $ConfigPath


		}


	}
} #end Function
