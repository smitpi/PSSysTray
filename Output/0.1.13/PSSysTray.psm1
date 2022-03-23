#region Private Functions
#endregion
#region Public Functions
#region New-PSSysTrayConfigFile.ps1
############################################
# source: New-PSSysTrayConfigFile.ps1
# Module: PSSysTray
# version: 0.1.13
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
$notes = "## Notes:`n"
$notes += "## Posible Entries:`n"
$notes += "## `t`tWindow: Hidden,Maximized,Normal,Minimized`n"
$notes += "## `t`tRunAsAdmin: Yes,No`n"


	[System.Collections.ArrayList]$Export = @()
	$export += [PSCustomObject]@{
		MainMenu   = 'Level1'
		Name       = 'TempScript'
		Command    = 'powershell.exe'
		Arguments  = 'C:\temp\script.ps1'
		Mode       = 'PSFile'
		Window     = 'hidden'
		RunAsAdmin = 'no'
	}
	$export += [PSCustomObject]@{
		MainMenu = 'Level2'
		Name = 'TempScript'
		Command = 'Powershell.exe'
		Arguments = 'get-command'
		Mode = 'PSCommand'
		Window = 'Maximized'
		RunAsAdmin = 'yes'
    }
	$export += [PSCustomObject]@{
		MainMenu = 'Level3'
		Name = 'open temp folder'
		Command = 'explorer.exe'
		Arguments = 'c:\Temp'
		Mode = 'Other'
		Window = 'Normal'
		RunAsAdmin = 'yes'
    }
	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

		$Configfile = (Join-Path $ConfigPath -ChildPath \PSSysTrayConfig.csv)
		$check = Test-Path -Path $Configfile -ErrorAction SilentlyContinue
		if (-not($check)) {
			Write-Output 'Config File does not exit, creating default settings.'
            $notes | Out-File -FilePath $Configfile -NoClobber -NoNewline
            $Export | ConvertTo-Csv -Delimiter ";" -NoTypeInformation | Out-File -FilePath $Configfile -Append -NoClobber
		} else {
			Write-Warning 'File exists, renaming file now'
			Rename-Item $Configfile -NewName "PSSysTrayConfig_$(Get-Date -Format ddMMyyyy_HHmm).csv"
            $notes | Out-File -FilePath $Configfile -NoClobber
            $Export | ConvertTo-Csv -Delimiter ";" -NoTypeInformation | Out-File -FilePath $Configfile -Append -NoClobber
		}

		if ($CreateShortcut) {
			$module = Get-Module PSSysTray
			if (![bool]$module) { $module = Get-Module PSSysTray -ListAvailable }
            if (![bool]$module) {throw "Could not find module"}

			$string = @"
`$PRModule = Get-ChildItem `"$((Join-Path ((Get-Item $module.ModuleBase).Parent).FullName "\*\$($module.name).psm1"))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
import-module `$PRModule.fullname -Force
Start-PSSysTray -ConfigFilePath $((Join-Path $ConfigPath -ChildPath \PSSysTrayConfig.csv -Resolve))
"@

	$DestFile = (Join-Path $ConfigPath -ChildPath \PSSysTray.ps1)
	if (test-path $DestFile) {
        Remove-Item ((Get-Item $DestFile).FullName).Replace("ps1","lnk")
        Remove-Item (Get-Item $DestFile).FullName
	}
    $PSSysTray = New-Item -Path $DestFile -ItemType File -Value $string

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
# version: 0.1.13
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

.EXAMPLE
Start-PSSysTray -ConfigFilePath C:\temp\PSSysTrayConfig.csv 

#>
Function Start-PSSysTray {
    [Cmdletbinding(SupportsShouldProcess = $true, HelpURI = 'https://smitpi.github.io/PSSysTray/Start-PSSysTray')]	    
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv') })]
        [string]$ConfigFilePath
    )

    if ($pscmdlet.ShouldProcess('Target', 'Operation')) {
        #region load assemblies
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
        #endregion
        #region Create from
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
        #endregion
        #region functions
        function AddEntry {

                
                $more = "y"
                do {
                Clear-Host
                Write-Host "Fill in the following:"
                [void]$config.Add([PSCustomObject]@{
                    MainMenu   = (read-host "MainMenu")
                    Name       = (read-host "Name")
                    Command    = (read-host "Command")
                    Arguments  = (read-host "Arguments")
                    Mode       = (read-host "Mode")
                    Window     = (read-host "Window")
                    RunAsAdmin = (read-host "RunAsAdmin")
                })
                $more = Read-Host "Add another entry (y\n)"
                } while ($more.ToLower() -notlike "n")
                Rename-Item $ConfigFilePath -NewName "PSSysTrayConfig-addentry-$(Get-Date -Format yyyy.MM.dd_HH.mm).csv" -Force
                $notes | Out-File -FilePath $ConfigFilePath -NoClobber -Force
                $config | Sort-Object -Property MainMenu | ConvertTo-Csv -Delimiter ";" -NoTypeInformation | Out-File -FilePath $ConfigFilePath -Append -NoClobber -Force
        }
        Function Invoke-Action {
            Param (
                [string]$name,
                [string]$command,
                [string]$arguments,
                [string]$mode,
                [string]$Window,
                [string]$RunAsAdmin
            )
            [hashtable]$processArguments = @{
                'PassThru'    = $true
                'FilePath'    = $command
                'WindowStyle' = 'Minimized'
            }

            if ( $RunAsAdmin -like 'yes' ) { $processArguments.Add( 'Verb' , 'RunAs' )}
            if ( $Window -contains 'Hidden' ) { $processArguments.WindowStyle = 'Hidden' }
            if ( $Window -contains 'Normal' ) { $processArguments.WindowStyle = 'Normal' }
            if ( $Window -contains 'Maximized' ) { $processArguments.WindowStyle = 'Maximized' }

            if ($mode -eq 'PSFile') { $AddedArguments = "-NoLogo  -NoProfile -ExecutionPolicy Bypass -File `"$arguments`"" }
            if ($mode -eq 'PSCommand') { $AddedArguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -command `"& {$arguments}`"" }
            if ($mode -eq 'Other') { $AddedArguments = $arguments}

            if (-not[string]::IsNullOrEmpty( $AddedArguments)) {$processArguments.Add( 'ArgumentList' , [Environment]::ExpandEnvironmentVariables( $AddedArguments)) }


            $process = $null
            $process = Start-Process @processArguments
            if (-not($process)) {[void][Windows.MessageBox]::Show( "Failed to run $($processArguments.FilePath)" , 'Action Error' , 'Ok' , 'Exclamation' )}
        }
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
                [scriptblock]$clickAction,
                [System.Windows.Forms.MenuItem]$MainMenu
            )

            #Initialization
            $MenuItem = New-Object System.Windows.Forms.MenuItem

            #Apply desired text
            if ($Text) { $MenuItem.Text = $Text}
            $MenuItem.add_click($clickAction)
            #Return our new MenuItem
            $MainMenu.MenuItems.AddRange($MenuItem)
        }
        function NMainMenu {
            param(
                [string]$Text = 'Placeholder Text'
            )
            $MainMenu = New-Object System.Windows.Forms.MenuItem
            $MainMenu.Text = $Text
            $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($MainMenu)
            $MainMenu
        }
        #endregion
        #region process csv file

        [System.Collections.ArrayList]$config = @()
        $notes = Get-Content $ConfigFilePath | Where-Object {$_ -like "##*"} 
        $config = Get-Content $ConfigFilePath | Where-Object {$_ -notlike "##*"} | ConvertFrom-Csv -Delimiter ";" 
        foreach ($main in ($config.mainmenu | Get-Unique)) {
            $tmpmenu = NMainMenu -Text $main
            $record = $config | Where-Object { $_.Mainmenu -like $main }
            foreach ($rec in $record) {
                #[scriptblock]$clickAction = [scriptblock]::Create( "Invoke-Action -control `$_ -name `"$($rec.Name)`" -command `"$($rec.command)`" -arguments `"$(($rec|Select-Object -ExpandProperty arguments -ErrorAction SilentlyContinue) -replace '"' , '`"`"')`" -mode $($rec.Mode) -options `"$(($rec|Select-Object -ExpandProperty options -ErrorAction SilentlyContinue) -split ',')`"" )
                [scriptblock]$clickAction = [scriptblock]::Create( "Invoke-Action -control `$_ -name `"$($rec.Name)`" -command `"$($rec.command)`" -arguments `"$(($rec|Select-Object -ExpandProperty arguments -ErrorAction SilentlyContinue) -replace '"' , '`"`"')`" -mode $($rec.Mode) -Window `"$($rec.Window)`" -RunAsAdmin `"$($rec.RunAsAdmin)`"" )
                NMenuItem -Text $rec.Name -clickAction $clickAction -MainMenu $tmpmenu
            }
        }
        #endregion
        #region Add-Entry
        $Add_Entry = New-Object System.Windows.Forms.MenuItem
        $Add_Entry.Text = 'Add Item'
        $Add_Entry.add_Click( {
        ShowConsole
        AddEntry
        HideConsole
            })
        $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Add_Entry)
        #endregion
        #region add exit button
        $Menu_Exit = New-Object System.Windows.Forms.MenuItem
        $Menu_Exit.Text = 'Exit'
        $Menu_Exit.add_Click( {
                $Systray_Tool_Icon.Visible = $false
                $window.Close()
                $window_Config.Close()
                Stop-Process $pid
            })
        $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)
        #endregion

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
