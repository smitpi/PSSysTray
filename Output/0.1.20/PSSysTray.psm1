#region Public Functions
#region Add-PSSysTrayEntry.ps1
######## Function 1 of 3 ##################
# Function:         Add-PSSysTrayEntry
# Module:           PSSysTray
# ModuleVersion:    0.1.20
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/26 15:49:24
# ModifiedOn:       2022/04/02 04:00:52
# Synopsis:         Add an entry in the csv config file.
#############################################
 
<#
.SYNOPSIS
Add an entry in the csv config file.

.DESCRIPTION
Add an entry in the csv config file.

.PARAMETER PSSysTrayConfigFile
Path to the config file created by New-PSSysTrayConfigFile

.PARAMETER Execute
Start the tool after adding the configuration.

.EXAMPLE
An Add-PSSysTrayEntry -PSSysTrayConfigFile C:\temp\PSSysTrayConfig.csv

#>
Function Add-PSSysTrayEntry {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSSysTray/Add-PSSysTrayEntry')]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { if ((Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv')) { $true}
                else {throw 'Not a valid config file.'} })]
        [System.IO.FileInfo]$PSSysTrayConfigFile,
        [switch]$Execute = $false
    )

    [System.Collections.ArrayList]$config = @()
    $notes = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -like '##*'}
    $config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~'

    $again = 'y'
    do {
        Clear-Host
        Write-Color 'Choose the Main Menu:' -Color DarkRed -StartTab 1 -LinesBefore 2
        $index = 0

        [System.Collections.ArrayList]$mainmenulist = @()
        $config.mainmenu | ForEach-Object {if ($_ -notin $mainmenulist) {[void]$mainmenulist.Add($_)}}

        $mainmenulist | ForEach-Object {
            Write-Color "$($index)) ", $_ -Color Yellow, Green
            $index++
        }
        Write-Color 'n) ', 'New Main Menu' -Color Yellow, Green
        $choose = Read-Host 'Answer'
        if ($choose.ToLower() -like 'n') {$MainMenu = Read-Host 'New Menu Name'}
        else {$MainMenu = $mainmenulist[$choose]}

        Write-Color 'The new item name:' -Color DarkRed -StartTab 1 -LinesBefore 2
        $name = Read-Host 'Answer'

        Write-Color 'Choose the mode:' -Color DarkRed -StartTab 1 -LinesBefore 2
        Write-Color '0) ', 'PowerShell Script file' -Color Yellow, Green
        Write-Color '1) ', 'PowerShell Command' -Color Yellow, Green
        Write-Color '2) ', 'Other Executable' -Color Yellow, Green
        $modechoose = Read-Host 'Answer'

        switch ($modechoose) {
            '0' {
                $mode = 'PSFile'
                $command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
                $arguments = Read-Host 'Path to .ps1 file'
            }
            '1' {
                $mode = 'PSCommand'
                $command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
                $arguments = Read-Host 'PowerShell command or scriptblock'

            }
            '2' {
                $mode = 'Other'
                $command = Read-Host 'Path to executable'
                $arguments = Read-Host 'Arguments for the executable'
            }
        }
        $cmd = [PSCustomObject]@{
            mode      = $mode
            command   = $command
            arguments = $arguments
        }

        Write-Color 'Choose the window size:' -Color DarkRed -StartTab 1 -LinesBefore 2
        Write-Color '0) ', 'Hidden' -Color Yellow, Green
        Write-Color '1) ', 'Normal' -Color Yellow, Green
        Write-Color '2) ', 'Minimized' -Color Yellow, Green
        Write-Color '3) ', 'Maximized' -Color Yellow, Green
        $modechoose = Read-Host 'Answer'

        switch ($modechoose) {
            '0' {$Window = 'Hidden'}
            '1' {$Window = 'Normal'}
            '2' {$Window = 'Minimized'}
            '3' {$Window = 'Maximized'}

        }

        Write-Color 'Run As Admin:' -Color DarkRed -StartTab 1 -LinesBefore 2
        Write-Color '0) ', 'Yes' -Color Yellow, Green
        Write-Color '1) ', 'No' -Color Yellow, Green
        $modechoose = Read-Host 'Answer'
        switch ($modechoose) {
            '0' {$RunAs = 'Yes'}
            '1' {$RunAs = 'No'}
        }
        if ($mainmenu -in $config.mainmenu) {
            $count = ($config.mainmenu | Where-Object {$_ -like $mainmenu}).count
            $config.Insert(($config.MainMenu.IndexOf("$mainmenu") + $count),[PSCustomObject]@{
                MainMenu   = $mainmenu
                Name       = $name
                Command    = $cmd.command
                Arguments  = $cmd.arguments
                Mode       = $cmd.mode
                Window     = $Window
                RunAsAdmin = $RunAs
            })
        }
        else {
            $config.Add([PSCustomObject]@{
                    MainMenu   = $mainmenu
                    Name       = $name
                    Command    = $cmd.command
                    Arguments  = $cmd.arguments
                    Mode       = $cmd.mode
                    Window     = $Window
                    RunAsAdmin = $RunAs
                })
        }
        $again = Read-Host 'Add More entries (y/n)'
    } while ($again.ToLower() -notlike 'n')

    Rename-Item $PSSysTrayConfigFile -NewName "PSSysTrayConfig-addentry-$(Get-Date -Format yyyy.MM.dd_HH.mm).csv" -Force
    $notes | Out-File -FilePath $PSSysTrayConfigFile -NoClobber -Force
    $config | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFile -Append -NoClobber -Force


    if ($Execute) {
        Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFile $($PSSysTrayConfigFile)}"""
    }
} #end Function
 
Export-ModuleMember -Function Add-PSSysTrayEntry
#endregion
 
#region New-PSSysTrayConfigFile.ps1
######## Function 2 of 3 ##################
# Function:         New-PSSysTrayConfigFile
# Module:           PSSysTray
# ModuleVersion:    0.1.20
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/22 11:39:20
# ModifiedOn:       2022/03/27 19:15:35
# Synopsis:         Creates the needed .csv file in the specified folder.
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
		[ValidateScript( { if (Test-Path $_) { $true}
				else {throw 'Not a valid config file.'} })]
		[System.IO.DirectoryInfo]$ConfigPath,
		[switch]$CreateShortcut = $false
	)
	$notes = "## Notes:`n"
	$notes += "## Posible Entries:`n"
	$notes += "## `t`tWindow: Hidden,Maximized,Normal,Minimized`n"
	$notes += "## `t`tMode: PSFile(Powershell .ps1 file), PSCommand (Powershell Command), Other (All other executables)`n"
	$notes += "## `t`tRunAsAdmin: Yes,No`n"
	$notes += "##`n"


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
		MainMenu   = 'Level2'
		Name       = 'TempCommand'
		Command    = 'Powershell.exe'
		Arguments  = 'get-command'
		Mode       = 'PSCommand'
		Window     = 'Maximized'
		RunAsAdmin = 'yes'
	}
	$export += [PSCustomObject]@{
		MainMenu   = 'Level3'
		Name       = 'open temp folder'
		Command    = 'explorer.exe'
		Arguments  = 'c:\Temp'
		Mode       = 'Other'
		Window     = 'Normal'
		RunAsAdmin = 'yes'
	}
	if ($pscmdlet.ShouldProcess('Target', 'Operation')) {

		$Configfile = (Join-Path $ConfigPath -ChildPath \PSSysTrayConfig.csv)
		$check = Test-Path -Path $Configfile -ErrorAction SilentlyContinue
		if (-not($check)) {
			Write-Output 'Config File does not exit, creating default settings.'
			$notes | Out-File -FilePath $Configfile -NoClobber -NoNewline
			$Export | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $Configfile -Append -NoClobber
		} else {
			Write-Warning 'File exists, renaming file now'
			Rename-Item $Configfile -NewName "PSSysTrayConfig_$(Get-Date -Format ddMMyyyy_HHmm).csv"
			$notes | Out-File -FilePath $Configfile -NoClobber
			$Export | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $Configfile -Append -NoClobber
		}

		if ($CreateShortcut) {
			$module = Get-Module PSSysTray
			if (![bool]$module) { $module = Get-Module PSSysTray -ListAvailable }
			if (![bool]$module) {throw 'Could not find module'}

			$string = @"
`$PRModule = Get-ChildItem `"$((Join-Path ((Get-Item $module.ModuleBase).Parent).FullName "\*\$($module.name).psm1"))`" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
Import-Module `$PRModule.fullname -Force
Start-PSSysTray -PSSysTrayConfigFile $((Join-Path $ConfigPath -ChildPath \PSSysTrayConfig.csv -Resolve))
"@

			$DestFile = (Join-Path $ConfigPath -ChildPath \PSSysTray.ps1)
			if (Test-Path $DestFile) {
				Remove-Item ((Get-Item $DestFile).FullName).Replace('ps1', 'lnk')
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
######## Function 3 of 3 ##################
# Function:         Start-PSSysTray
# Module:           PSSysTray
# ModuleVersion:    0.1.20
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/22 11:40:35
# ModifiedOn:       2022/04/02 03:58:17
# Synopsis:         This function reads csv config file and creates the gui in your system tray.
#############################################
 
<#
.SYNOPSIS
This function reads csv config file and creates the gui in your system tray.

.DESCRIPTION
This function reads csv config file and creates the gui in your system tray.

.PARAMETER PSSysTrayConfigFile
Path to the config file created by New-PSSysTrayConfigFile

.EXAMPLE
Start-PSSysTray -PSSysTrayConfigFile C:\temp\PSSysTrayConfig.csv

#>
Function Start-PSSysTray {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSSysTray/Start-PSSysTray')]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { if ((Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv')) { $true}
                else {throw 'Not a valid config file.'} })]
        [System.IO.FileInfo]$PSSysTrayConfigFile
    )

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
    $Systray_Tool_Icon.Text = "PSSysTray Utils (Ver:$($module.Version))"
    # Systray icon
    $Systray_Tool_Icon.Icon = $icon
    $Systray_Tool_Icon.Visible = $true
    $contextmenu = New-Object System.Windows.Forms.ContextMenu
    $Systray_Tool_Icon.ContextMenu = $contextmenu
    #endregion
    #region functions
    Function Invoke-Action {
        Param (
            [string]$command,
            [string]$arguments,
            [string]$mode,
            [string]$Window,
            [string]$RunAsAdmin
        )
        [hashtable]$processArguments = @{
            'PassThru'    = $true
            'FilePath'    = $command
        }

        if ( $RunAsAdmin -like 'yes' ) { $processArguments.Add( 'Verb' , 'RunAs' )}
        if ( $Window -contains 'Hidden' ) { $processArguments.Add('WindowStyle' , 'Hidden') }
        if ( $Window -contains 'Normal' ) { $processArguments.Add('WindowStyle' , 'Normal') }
        if ( $Window -contains 'Maximized' ) { $processArguments.Add('WindowStyle' , 'Maximized') }
        if ( $Window -contains 'Minimized' ) { $processArguments.Add('WindowStyle' , 'Minimized') }

        if ($mode -eq 'PSFile') { $AddedArguments = "-NoLogo  -NoProfile -ExecutionPolicy Bypass -File `"$arguments`"" }
        if ($mode -eq 'PSCommand') { $AddedArguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -command `"& {$arguments}`"" }
        if ($mode -eq 'Other') { $AddedArguments = $arguments}

        if (-not[string]::IsNullOrEmpty( $AddedArguments)) {$processArguments.Add( 'ArgumentList' , [Environment]::ExpandEnvironmentVariables( $AddedArguments)) }

        ShowConsole
        #Clear-Host
        Write-Color 'Running the following:' -Color DarkYellow -ShowTime
        Write-Color 'Command: ', $command -Color Cyan, Green -ShowTime
        Write-Color 'Arguments: ', $arguments -Color Cyan, Green -ShowTime
        Write-Color 'Mode: ', $Mode -Color Cyan, Green -ShowTime
        Write-Color 'Window: ', $Window -Color Cyan, Green -ShowTime
        Write-Color 'RunAsAdmin: ', $RunAsAdmin -Color Cyan, Green -ShowTime -LinesAfter 2
        try {
            Start-Process @processArguments
            Write-Color 'Process Completed' -ShowTime -Color DarkYellow
        } catch {
            $Text = $This.Text
            [System.Windows.Forms.MessageBox]::Show("Failed to launch $Text`n`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)") > $null
        }
        HideConsole
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
    $config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~'
    foreach ($main in ($config.mainmenu | Get-Unique -AsString)) {
        $tmpmenu = NMainMenu -Text $main
        $record = $config | Where-Object { $_.Mainmenu -like $main }
        foreach ($rec in $record) {
            [scriptblock]$clickAction = [scriptblock]::Create( "Invoke-Action -control `$_ -name `"$($rec.Name)`" -command `"$($rec.command)`" -arguments `"$(($rec|Select-Object -ExpandProperty arguments -ErrorAction SilentlyContinue) -replace '"' , '`"`"')`" -mode $($rec.Mode) -Window `"$($rec.Window)`" -RunAsAdmin `"$($rec.RunAsAdmin)`"" )
            NMenuItem -Text $rec.Name -clickAction $clickAction -MainMenu $tmpmenu
        }
    }
    #endregion
    #region Add-Entry
    $line = New-Object System.Windows.Forms.MenuItem
    $line.Text = '___________________________'
    $line.add_click({
            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFile $($PSSysTrayConfigFile)}"""
            $Systray_Tool_Icon.Visible = $false
            Stop-Process $pid
        })
    $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($line)
    $Add_Entry = New-Object System.Windows.Forms.MenuItem
    $Add_Entry.Text = 'Add Item'
    $Add_Entry.add_Click( {
            ShowConsole
            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile  -ExecutionPolicy bypass -command ""& {Add-PSSysTrayEntry -PSSysTrayConfigFile $($PSSysTrayConfigFile) -Execute }"" -wait"
            $Systray_Tool_Icon.Visible = $false
            Stop-Process $pid
            HideConsole
        })
    $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Add_Entry)
    #endregion
    #region add exit button
    $Menu_Exit = New-Object System.Windows.Forms.MenuItem

    $Menu_Exit.Text = 'Exit'
    $Menu_Exit.add_Click( {
            $Systray_Tool_Icon.Visible = $false
            Stop-Process $pid
        })
    $Systray_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)
    #endregion
    #region Start gui
    # Create an application context for it to all run within.
    # This helps with responsiveness, especially when clicking Exit.
    HideConsole
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [void][System.Windows.Forms.Application]::Run($appContext)
    #endregion
} #end Function

 
Export-ModuleMember -Function Start-PSSysTray
#endregion
 
#endregion
 
