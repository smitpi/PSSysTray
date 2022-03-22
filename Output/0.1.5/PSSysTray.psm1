#region Private Functions
########### Private Function ###############
# source: New-PSSysTrayConfigFile.ps1
# Module: PSSysTray
############################################

<#PSScriptInfo

.VERSION 0.1.0

.GUID 28d6de4c-10fc-45c0-8d96-1869a965134c

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [27/10/2021_05:31] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
Creates the config file for Start-PSSysTray

#>

<#
.SYNOPSIS
Creates the config file for Start-PSSysTray

.DESCRIPTION
Creates the config file for Start-PSSysTray

.PARAMETER ConfigPath
Path where config file will be saved.

.PARAMETER CreateShortcut
Create a shortcut to a .ps1 file that will launch the gui.

.EXAMPLE
New-PSSysTrayConfigFile -ConfigPath C:\temp -CreateShortcut

#>
Function New-PSSysTrayConfigFile {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSSysTray/New-PSSysTrayConfigFile/')]
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
            $module = Get-Module pslauncher
            if (![bool]$module) { $module = Get-Module pslauncher -ListAvailable }

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
            $Shortcut.Arguments = "-NoLogo -NoProfile -ExecutionPolicy bypass -file `"$($PSSysTray.FullName)`""
            $icon = Get-Item (Join-Path $module.ModuleBase .\Private\PSSysTray.ico)
            $Shortcut.IconLocation = $icon.FullName
            $Shortcut.Save()
            Start-Process explorer.exe $ConfigPath


        }


    }
} #end Function
########### Private Function ###############
# source: Start-PSSysTray.ps1
# Module: PSSysTray
############################################

<#PSScriptInfo

.VERSION 0.1.0

.GUID 41aa308f-60e2-499b-aa12-a92e73f4a1c1

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [24/10/2021_05:59] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Gui menu app in your systray with custom executable functions

#>

<#
.SYNOPSIS
This function launches the System Tray GUI.

.DESCRIPTION
This function launches the System Tray GUI.

.PARAMETER ConfigFilePath
Path to the csv file created by the New-PSSysTrayConfigFile function.

.EXAMPLE
Start-PSSysTray -ConfigFilePath C:\temp\PSSysTrayConfig.csv

#>
Function Start-PSSysTray {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSSysTray/Start-PSSysTray/')]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv') })]
        [string]$ConfigFilePath
    )
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

        # Declare assemblies
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | Out-Null

        # Add an icon to the systray button
        $module = Get-Module pslauncher
        if (![bool]$module) { $module = Get-Module pslauncher -ListAvailable }


        $icopath = (Join-Path $module.ModuleBase '\Private\PSSysTray.ico') | Get-Item
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($icopath.FullName)

        # Create object for the systray
        $Systray_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
        # Text displayed when you pass the mouse over the systray icon
        $Systray_Tool_Icon.Text = 'PSSysTray Utils'
        # Systray icon
        $Systray_Tool_Icon.Icon = $icon
        $Systray_Tool_Icon.Visible = $true
        $contextmenu = New-Object System.Windows.Forms.ContextMenu
        $Systray_Tool_Icon.ContextMenu = $contextmenu

        function ShowConsole {
            $PSConsole = [Console.Window]::GetConsoleWindow()
            [Console.Window]::ShowWindow($PSConsole, 5)
        }
        function HideConsole {
            $PSConsole = [Console.Window]::GetConsoleWindow()
            [Console.Window]::ShowWindow($PSConsole, 0)
        }
        function NMenuItem {
            param(
                [string]$Text = 'Placeholder Text',
                $MyScriptPath,
                [ValidateSet('PSFile', 'PSCommand', 'Other')]
                [string]$method,
                [System.Windows.Forms.MenuItem]$MainMenu
            )

            #Initialization
            $MenuItem = New-Object System.Windows.Forms.MenuItem

            #Apply desired text
            if ($Text) {
                $MenuItem.Text = $Text
            }

            #Apply click event logic
            if ($MyScriptPath -and !$ExitOnly) {
                $MenuItem | Add-Member -Name MyScriptPath -Value $MyScriptPath -MemberType NoteProperty
                if ($method -eq 'PSFile') {
                    $MenuItem.Add_Click( {
                            ShowConsole
                            $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event
                            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -File `"$MyScriptPath`"" -ErrorAction Stop
                            HideConsole
                        })
                }

                if ($method -eq 'PSCommand') {
                    $MenuItem.Add_Click( {
                            ShowConsole
                            $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event
                            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -Command `"& {$MyScriptPath}""" -ErrorAction Stop
                            HideConsole
                        })
                }
                if ($method -eq 'Other') {
                    $MenuItem.Add_Click( {
                            ShowConsole
                            $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event
                            Start-Process $MyScriptPath
                            HideConsole

                        })
                }

            }

            #Return our new MenuItem
            $MainMenu.MenuItems.AddRange($MenuItem)
        }
        function NMainMenu {
            param(
                [string]$Text = 'Placeholder Text',
                [switch]$AddExit = $false
            )
            $MainMenu = New-Object System.Windows.Forms.MenuItem
            $MainMenu.Text = $Text
            $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($MainMenu)
            $MainMenu

            if ($AddExit) {
                $Menu_Exit = New-Object System.Windows.Forms.MenuItem
                $Menu_Exit.Text = 'Exit'
                $Menu_Exit.add_Click( {
                        $Systray_Tool_Icon.Visible = $false
                        $window.Close()
                        # $window_Config.Close()
                        Stop-Process $pid
                    })
                $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)
            }
        }

        $config = Import-Csv -Path $ConfigFilePath
        foreach ($main in ($config.mainmenu | Get-Unique)) {
            $tmpmenu = NMainMenu -Text $main
            $config | Where-Object { $_.Mainmenu -like $main } | ForEach-Object { NMenuItem -Text $_.ScriptName -MyScriptPath $_.ScriptPath -method $_.mode -MainMenu $tmpmenu }
        }
        $Menu_Exit = New-Object System.Windows.Forms.MenuItem
        $Menu_Exit.Text = 'Exit'
        $Menu_Exit.add_Click( {
                $Systray_Tool_Icon.Visible = $false
                $window.Close()
                $window_Config.Close()
                Stop-Process $pid
            })
        $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)


        # Create an application context for it to all run within.
        # This helps with responsiveness, especially when clicking Exit.
        HideConsole
        $appContext = New-Object System.Windows.Forms.ApplicationContext
        [void][System.Windows.Forms.Application]::Run($appContext)


    }
} #end Function

#endregion
#region Public Functions
#region New-PSSysTrayConfigFile.ps1
############################################
# source: New-PSSysTrayConfigFile.ps1
# Module: PSSysTray
# version: 0.1.5
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Creates the needed .csv file in the specified folder.

.DESCRIPTION
Creates the needed .csv file in the specified folder.

.PARAMETER ConfigPath
Path to where the config file will be saved.

.PARAMETER CreateShortcut
Create a shortcut to a .ps1 file that will launch the gui.

.PARAMETER Confirm
Will ask before changes are made.

.PARAMETER WhatIf
Runs the script without changes.

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
 
Export-ModuleMember -Function New-PSSysTrayConfigFile
#endregion
 
#region Start-PSSysTray.ps1
############################################
# source: Start-PSSysTray.ps1
# Module: PSSysTray
# version: 0.1.5
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
This function reads csv config file and creates the gui in your system tray.

.DESCRIPTION
This function reads csv config file and creates the gui in your system tray.

.PARAMETER ConfigFilePath
Path to the config file created by New-PSSysTrayConfigFile

.PARAMETER Confirm
Will ask before changes are made.

.PARAMETER WhatIf
Runs the script without changes.

.EXAMPLE
Start-PSSysTray -ConfigFilePath C:\temp\PSSysTrayConfig.csv 

#>
Function Start-PSSysTray {
		[Cmdletbinding(upportsShouldProcess = $true, HelpURI = "https://smitpi.github.io/PSSysTray/Start-PSSysTray")]	    
		Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv') })]
        [string]$ConfigFilePath
    )
    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

        Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

        # Declare assemblies
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | Out-Null

        # Add an icon to the systray button
        $module = Get-Module PSSysTray
        if (![bool]$module) { $module = Get-Module PSSysTray -ListAvailable }


        $icopath = (Join-Path $module.ModuleBase '\Private\PSSysTray.ico') | Get-Item
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($icopath.FullName)

        # Create object for the systray
        $Systray_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
        # Text displayed when you pass the mouse over the systray icon
        $Systray_Tool_Icon.Text = 'PSSysTray Utils'
        # Systray icon
        $Systray_Tool_Icon.Icon = $icon
        $Systray_Tool_Icon.Visible = $true
        $contextmenu = New-Object System.Windows.Forms.ContextMenu
        $Systray_Tool_Icon.ContextMenu = $contextmenu

        function ShowConsole {
            $PSConsole = [Console.Window]::GetConsoleWindow()
            [Console.Window]::ShowWindow($PSConsole, 5)
        }
        function HideConsole {
            $PSConsole = [Console.Window]::GetConsoleWindow()
            [Console.Window]::ShowWindow($PSConsole, 0)
        }
        function NMenuItem {
            param(
                [string]$Text = 'Placeholder Text',
                $MyScriptPath,
                [ValidateSet('PSFile', 'PSCommand', 'Other')]
                [string]$method,
                [System.Windows.Forms.MenuItem]$MainMenu
            )

            #Initialization
            $MenuItem = New-Object System.Windows.Forms.MenuItem

            #Apply desired text
            if ($Text) {
                $MenuItem.Text = $Text
            }

            #Apply click event logic
            if ($MyScriptPath -and !$ExitOnly) {
                $MenuItem | Add-Member -Name MyScriptPath -Value $MyScriptPath -MemberType NoteProperty
                if ($method -eq 'PSFile') {
                    $MenuItem.Add_Click( {
                            ShowConsole
                            $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event
                            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoProfile -NoLogo -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$MyScriptPath`"" -ErrorAction Stop
                            HideConsole
                        })
                }

                if ($method -eq 'PSCommand') {
                    $MenuItem.Add_Click( {
                            ShowConsole
                            $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event
                            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -Command `"& {$MyScriptPath}""" -ErrorAction Stop
                            HideConsole
                        })
                }
                if ($method -eq 'Other') {
                    $MenuItem.Add_Click( {
                            ShowConsole
                            $MyScriptPath = $This.MyScriptPath #Used to find proper path during click event
                            Start-Process $MyScriptPath
                            HideConsole

                        })
                }

            }

            #Return our new MenuItem
            $MainMenu.MenuItems.AddRange($MenuItem)
        }
        function NMainMenu {
            param(
                [string]$Text = 'Placeholder Text',
                [switch]$AddExit = $false
            )
            $MainMenu = New-Object System.Windows.Forms.MenuItem
            $MainMenu.Text = $Text
            $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($MainMenu)
            $MainMenu

            if ($AddExit) {
                $Menu_Exit = New-Object System.Windows.Forms.MenuItem
                $Menu_Exit.Text = 'Exit'
                $Menu_Exit.add_Click( {
                        $Systray_Tool_Icon.Visible = $false
                        $window.Close()
                        # $window_Config.Close()
                        Stop-Process $pid
                    })
                $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)
            }
        }

        $config = Import-Csv -Path $ConfigFilePath
        foreach ($main in ($config.mainmenu | Get-Unique)) {
            $tmpmenu = NMainMenu -Text $main
            $config | Where-Object { $_.Mainmenu -like $main } | ForEach-Object { NMenuItem -Text $_.ScriptName -MyScriptPath $_.ScriptPath -method $_.mode -MainMenu $tmpmenu }
        }
        $Menu_Exit = New-Object System.Windows.Forms.MenuItem
        $Menu_Exit.Text = 'Exit'
        $Menu_Exit.add_Click( {
                $Systray_Tool_Icon.Visible = $false
                $window.Close()
                $window_Config.Close()
                Stop-Process $pid
            })
        $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)


        # Create an application context for it to all run within.
        # This helps with responsiveness, especially when clicking Exit.
        HideConsole
        $appContext = New-Object System.Windows.Forms.ApplicationContext
        [void][System.Windows.Forms.Application]::Run($appContext)


    }
} #end Function

 
Export-ModuleMember -Function Start-PSSysTray
#endregion
 
#endregion
