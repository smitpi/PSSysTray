#region Public Functions
#region Edit-PSSysTrayConfig.ps1
######## Function 1 of 3 ##################
# Function:         Edit-PSSysTrayConfig
# Module:           PSSysTray
# ModuleVersion:    0.1.13.0
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/08/08 20:06:26
# ModifiedOn:       2022/08/15 08:28:34
# Synopsis:         Edit the config File
#############################################
 
<#
.SYNOPSIS
Edit the config File

.DESCRIPTION
Edit the config File


.PARAMETER PSSysTrayConfigFile
Path to the config file created by New-PSSysTrayConfigFile.

.PARAMETER Execute
Start the tool after adding the configuration.

.EXAMPLE
Edit-PSSysTrayConfig -PSSysTrayConfigFile C:\temp\PSSysTrayConfig.csv

#>
Function Edit-PSSysTrayConfig {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/PSSysTray/Edit-PSSysTrayConfig')]
    [OutputType([System.Object[]])]
    Param (
        [System.IO.FileInfo]$PSSysTrayConfigFile,
        [switch]$Execute
    )

    #region Load csv
    try {
        [System.Collections.Generic.List[psobject]]$Script:config = @()
        $Script:config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~' -ErrorAction Stop
        $Script:Notes = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -like '##*'}
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'CSV | *.csv' }
        [void]$FileBrowser.ShowDialog()
        $PSSysTrayConfigFile = Get-Item $FileBrowser.FileName
        $Script:config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~'
        $Script:Notes = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -like '##*'}
    }
    #endregion

    Write-Color 'Please Choose' -Color DarkCyan -LinesBefore 2 -LinesAfter 1
    Write-Color '1) ', 'Add a new Item' -Color Yellow, Green
    Write-Color '2) ', 'Rearange Main Menu' -Color Yellow, Green
    Write-Color '3) ', 'Rearange items in a Menu' -Color Yellow, Green
    Write-Color '4) ', 'Remove an Item' -Color Yellow, Green
    Write-Color 'Q) ', 'Quit' -Color Yellow, Green
    $Number = Read-Host 'Number'

    if ($Number.ToLower() -like 'q') {exit}

    if ($number -like '1') {
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

            Write-Color 'Run As another User:' -Color DarkRed -StartTab 1 -LinesBefore 2
            Write-Color '0) ', 'Yes' -Color Yellow, Green
            Write-Color '1) ', 'No' -Color Yellow, Green
            $modechoose = Read-Host 'Answer'
            switch ($modechoose) {
                '0' {$RunAsUser = Read-Host 'PSCredential Variable Name '}
                '1' {$RunAsUser  = 'LoggedInUser'}
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
                $config.Insert(($config.MainMenu.IndexOf("$mainmenu") + $count), [PSCustomObject]@{
                        MainMenu   = $mainmenu
                        Name       = $name
                        Command    = $cmd.command
                        Arguments  = $cmd.arguments
                        Mode       = $cmd.mode
                        Window     = $Window
                        RunAsUser  = $RunAsUser
                        RunAsAdmin = $RunAs
                    })
            } else {
                [void]$config.Add([PSCustomObject]@{
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

        Rename-Item $PSSysTrayConfigFile -NewName "PSSysTrayConfig-editentry-$(Get-Date -Format yyyy.MM.dd_HH.mm.ss).csv" -Force
        $notes | Out-File -FilePath $PSSysTrayConfigFile -NoClobber -Force
        $config | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFile -Append -NoClobber -Force

    }
    if ($Number -like '2') {
        [System.Collections.Generic.List[psobject]]$newconfig = @()
        do {
            Clear-Host
            $index = 0
            [System.Collections.ArrayList]$mainmenu = @()
            $config.mainmenu | Get-Unique | ForEach-Object {[void]$mainmenu.add($_)}
            $mainmenu | ForEach-Object {
                Write-Color "$($index)) ", $($_) -Color Yellow, Green
                $index++
            }
            $choose = Read-Host 'Next Item'
            $tmpitems = $config | Where-Object {$_.mainmenu -like $mainmenu[$choose]}
            foreach ($item in $tmpitems) {
                [void]$newconfig.Add($item)
                [void]$config.Remove($item)
            }
        }
        while (($config.mainmenu).count -gt 0)
        Rename-Item $PSSysTrayConfigFile -NewName "PSSysTrayConfig-editentry-$(Get-Date -Format yyyy.MM.dd_HH.mm.ss).csv" -Force
        $notes | Out-File -FilePath $PSSysTrayConfigFile -NoClobber -Force
        $newconfig | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFile -Append -NoClobber -Force
    }
    if ($Number -like '3') {
        Clear-Host
        $main = ($config.mainmenu | Get-Unique)
        $index = 0
        foreach ($menu in $main) {
            Write-Color "$($index)) ", $($menu) -Color Yellow, Green
            $index++
        }
        $MainChoose = Read-Host 'Choose Main Menu'
        [System.Collections.Generic.List[psobject]]$newconfig = @()
        $IndexOf = $config.IndexOf(($config | Where-Object {$_.mainmenu -like $main[$MainChoose]})[0])
        do {
            $index = 0
            Clear-Host
            $config | Where-Object {$_.mainmenu -like $main[$MainChoose]} | ForEach-Object {
                Write-Color "$($index)) ", $($_.name) -Color Yellow, Green
                $index++
            }
            $choose = Read-Host 'Next item'
            [void]$newconfig.Add(($config | Where-Object {$_.mainmenu -like $main[$MainChoose]})[$choose])
            [void]$config.Remove(($config | Where-Object {$_.mainmenu -like $main[$MainChoose]})[$choose])
        }
        while (($config | Where-Object {$_.mainmenu -like $main[$MainChoose]}).count -gt 0)
        [void]$config.InsertRange($IndexOf, $newconfig)

        Rename-Item $PSSysTrayConfigFile -NewName "PSSysTrayConfig-editentry-$(Get-Date -Format yyyy.MM.dd_HH.mm.ss).csv" -Force
        $notes | Out-File -FilePath $PSSysTrayConfigFile -NoClobber -Force
        $config | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFile -Append -NoClobber -Force
    }
    if ($Number -like '4') {
        do {
            Clear-Host
            $index = 0
            $config | ForEach-Object {Write-Color "$($index)) ", "$($_.mainmenu) - ", $($_.name) -Color Yellow, Cyan, Green; $index++}
            Write-Color 'q) ', 'To Exit' -Color Yellow, Green
            $choose = Read-Host 'Index Number'
            if ($choose.ToString().ToLower() -notlike 'q') { [void]$config.Remove($config[$choose])}
        } while ($choose.ToString().ToLower() -notlike 'q')

        Rename-Item $PSSysTrayConfigFile -NewName "PSSysTrayConfig-editentry-$(Get-Date -Format yyyy.MM.dd_HH.mm.ss).csv" -Force
        $notes | Out-File -FilePath $PSSysTrayConfigFile -NoClobber -Force
        $config | ConvertTo-Csv -Delimiter '~' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFile -Append -NoClobber -Force
    }

    if ($Execute) {
        Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFile $($PSSysTrayConfigFile)}"""
    }
} #end Function
 
Export-ModuleMember -Function Edit-PSSysTrayConfig
#endregion
 
#region New-PSSysTrayConfigFile.ps1
######## Function 2 of 3 ##################
# Function:         New-PSSysTrayConfigFile
# Module:           PSSysTray
# ModuleVersion:    0.1.13.0
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/22 11:39:20
# ModifiedOn:       2022/08/09 04:49:14
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
Create a shortcut to a .ps1 file that will launch the GUI.

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
	$notes += "## Possible Entries:`n"
	$notes += "## `t`tWindow: Hidden,Maximized,Normal,Minimized`n"
	$notes += "## `t`tMode: PSFile(PowerShell .ps1 file), PSCommand (PowerShell Command), Other (All other executables)`n"
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
		RunAsUser  = 'LoggedInUser'
		RunAsAdmin = 'no'
	}
	$export += [PSCustomObject]@{
		MainMenu   = 'Level2'
		Name       = 'TempCommand'
		Command    = 'Powershell.exe'
		Arguments  = 'get-command'
		Mode       = 'PSCommand'
		Window     = 'Maximized'
		RunAsUser  = 'LoggedInUser'
		RunAsAdmin = 'yes'
	}
	$export += [PSCustomObject]@{
		MainMenu   = 'Level3'
		Name       = 'open temp folder'
		Command    = 'explorer.exe'
		Arguments  = 'c:\Temp'
		Mode       = 'Other'
		Window     = 'Normal'
		RunAsUser  = 'LoggedInUser'
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
# ModuleVersion:    0.1.13.0
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/22 11:40:35
# ModifiedOn:       2022/08/15 08:23:19
# Synopsis:         This function reads csv config file and creates the GUI in your system tray.
#############################################
 
<#
.SYNOPSIS
This function reads csv config file and creates the GUI in your system tray.

.DESCRIPTION
This function reads csv config file and creates the GUI in your system tray.

.PARAMETER PSSysTrayConfigFile
Path to the config file created by New-PSSysTrayConfigFile

.EXAMPLE
Start-PSSysTray -PSSysTrayConfigFile C:\temp\PSSysTrayConfig.csv

#>
Function Start-PSSysTray {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSSysTray/Start-PSSysTray')]
    Param (
        [System.IO.FileInfo]$PSSysTrayConfigFile
    )

    #region Load csv
    try {
        [System.Collections.Generic.List[psobject]]$Script:config = @()
        $Script:config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~' -ErrorAction Stop
    } catch {
        Add-Type -AssemblyName System.Windows.Forms
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Filter = 'CSV | *.csv' }
        [void]$FileBrowser.ShowDialog()
        $PSSysTrayConfigFile = Get-Item $FileBrowser.FileName
        $Script:config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~'
    }
    #region Checking for credentials
    $users = $config.RunAsUser | Where-Object {$_ -notlike 'LoggedInUser'}
    foreach ($User in ($users | Sort-Object -Unique)) {
        $exists = Get-Variable -Name $User -ErrorAction SilentlyContinue
        $Vartype = (Get-Variable -Name $User -ErrorAction SilentlyContinue).Value.GetType().Name
        if (-not($exists) -or $Vartype -notlike 'PSCredential') {
            $tmp = Get-Credential -Message "Username and password for $($User)"
            New-Variable -Name $User -Value $tmp -Option AllScope -Visibility Public -Scope global -Force
            Write-Color '[PSCredential]: ', "$($User): ", 'Complete' -Color Yellow, Cyan, Green
        } else {Write-Color '[PSCredential]: ', "$($User): ", 'Already Created' -Color Yellow, Cyan, DarkGray}
    }

    #endregion
    #region load assemblies v
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'
    # Declare assemblies
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | Out-Null
    # $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
    #endregion

    #region Create form
    # Add an icon to the systray button
    $module = Get-Module PSSysTray
    if (![bool]$module) { $module = Get-Module PSSysTray -ListAvailable }
    $module = $module | Sort-Object -Property Version | Select-Object -First 1
    $icopath = (Join-Path $module.ModuleBase '\Private\PSSysTray.ico') | Get-Item
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($icopath.FullName)

    $Exit_Icon_Path = (Join-Path $module.ModuleBase '\Private\exit.png') | Get-Item
    $Exit_Icon = [System.Drawing.Bitmap]::FromFile($Exit_Icon_Path.FullName)
    $Edit_Icon_Path = (Join-Path $module.ModuleBase '\Private\edit.png') | Get-Item
    $Edit_Icon = [System.Drawing.Bitmap]::FromFile($Edit_Icon_Path.FullName)
    $Menu_Icon_Path = (Join-Path $module.ModuleBase '\Private\menu.png') | Get-Item
    $Menu_Icon = [System.Drawing.Bitmap]::FromFile($Menu_Icon_Path.FullName)

    # Create object for the systray
    $Systray_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
    # Text displayed when you pass the mouse over the systray icon
    $Systray_Tool_Icon.Text = "PSSysTray Utils (Ver:$($module.Version))"
    # Systray icon
    $Systray_Tool_Icon.Icon = $icon
    $Systray_Tool_Icon.Visible = $true
    $contextmenu = New-Object System.Windows.Forms.ContextMenuStrip
    #endregion
    #region functions
    # function ShowConsole {
    #     $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 5)
    # }
    # function HideConsole {
    #     $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
    # }
    Function Invoke-Action {
        Param (
            [string]$command,
            [string]$arguments,
            [string]$mode,
            [string]$Window,
            [string]$RunAsUser,
            [string]$RunAsAdmin
        )
        [hashtable]$processArguments = @{
            #'PassThru' = $($true)
            'FilePath' = $command
        }

        if ( $RunAsAdmin -like 'yes' ) { $processArguments.Add( 'Verb' , 'RunAs' )}
        if ( $Window -contains 'Hidden') { $processArguments.Add('WindowStyle' , 'Hidden') }
        if ( $Window -contains 'Normal') { $processArguments.Add('WindowStyle' , 'Normal') }
        if ( $Window -contains 'Maximized') { $processArguments.Add('WindowStyle' , 'Maximized') }
        if ( $Window -contains 'Minimized') { $processArguments.Add('WindowStyle' , 'Minimized') }

        if ($mode -eq 'PSFile') { $AddedArguments = "-NoLogo  -NoProfile -ExecutionPolicy Bypass -File `"$arguments`"" }
        if ($mode -eq 'PSCommand') { $AddedArguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -command ""(& {$arguments})""" }
        if (-not($mode -eq 'Other') -and $LoggingEnabled) {$AddedArguments = '-NoExit ' + $AddedArguments}
        if ($mode -eq 'Other') { $AddedArguments = $arguments}
        if (-not[string]::IsNullOrEmpty( $AddedArguments)) {$processArguments.Add( 'ArgumentList' , [Environment]::ExpandEnvironmentVariables( $AddedArguments)) }
        
        if ($RunAsUser -like 'LoggedInUser') {
            try {
                Write-Color 'Running the following ', 'as LoggonUser:' -Color DarkYellow, DarkCyan -ShowTime
                $processArguments.GetEnumerator().name | ForEach-Object {Write-Color ('{0,-15}:' -f "$($_)"), ('{0}' -f "$($processArguments.$($_))") -ForegroundColor Cyan, Green -ShowTime}
                Start-Process @processArguments -ErrorAction Stop
            } catch {
                $Text = $This.Text
                [System.Windows.Forms.MessageBox]::Show("Failed to launch $Text`n`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)") > $null
            }
        } else {
            try {
                $ModProcessArg = $processArguments
                $ModProcessArg.ArgumentList = "'" + $($ModProcessArg.ArgumentList) + "'"
                $params = "Start-Process $([string]::Join(' ', ($ModProcessArg.GetEnumerator() | ForEach-Object {"-$($_.Key) $($_.Value)"})))"
                $BigHash = @{
                    'FilePath'     = 'powershell.exe'
                    'ArgumentList' = "-NoLogo -NoProfile -ExecutionPolicy Bypass -command ""(& {$params})"""
                    'WindowStyle'  = 'Hidden'
                    'Credential'   = (Get-Variable -Name $RunAsUser -ValueOnly)
                }
                if ($LoggingEnabled) {$BigHash.ArgumentList = '-NoExit ' + $BigHash.ArgumentList}
                Write-Color 'Running the following ', "as $((Get-Variable -Name $RunAsUser -ValueOnly).username):" -Color DarkYellow, DarkCyan -ShowTime
                $BigHash.GetEnumerator().name | ForEach-Object {Write-Color ('{0,-15}:' -f "$($_)"), ('{0}' -f "$($BigHash.$($_))") -ForegroundColor Cyan, Green -ShowTime}
                Start-Process @BigHash
            } catch {
                $Text = $This.Text
                [System.Windows.Forms.MessageBox]::Show("Failed to launch $Text`n`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)") > $null
            }
        }
    }
    function NMenuItem {
        param(
            [string]$Text = 'Placeholder Text',
            [scriptblock]$clickAction,
            [string]$command,
            [System.Windows.Forms.ToolStripMenuItem]$MainMenu
        )

        $MenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
        $MenuItem.Text = $Text
        $MenuItem.add_click($clickAction)

        try {
            $commanditem = Get-Item $command -ErrorAction Stop
        } catch {$commanditem = (Get-Item (Get-Command $command).Source)}

        $tmpicon = [System.Drawing.Icon]::ExtractAssociatedIcon($commanditem.FullName)
        $MenuItem.Image = [System.Drawing.Bitmap]$tmpicon.ToBitmap()
        
        $MainMenu.DropDownItems.Add($MenuItem)
    }
    function NMainMenu {
        param(
            [string]$Text = 'Placeholder Text'
        )
        $MainMenu = $contextmenu.Items.Add("$($Text)")
        $MainMenu.Image = $Menu_Icon
        $MainMenu
    }
    function EnableLogging {
        ShowConsole
        $script:LoggingEnabled = $True
        $script:GUIlogpath = "$($env:TEMP)\PSLauncher-$(Get-Date -Format yyyy.MM.dd-HH.mm).log"
        Write-Color 'Creating log file: ', $($GUIlogpath) -Color DarkYellow, DarkRed -ShowTime -LinesBefore 1
        Write-Color 'Starting Transcript.' -Color DarkYellow -ShowTime -LinesAfter 2
        Start-Transcript -Path $GUIlogpath -IncludeInvocationHeader -Force -NoClobber
    }
    function DisableLogging {
        Write-Color 'Stopping Transcript.' -Color DarkYellow -ShowTime -LinesBefore 2
        Write-Color 'Opening log file: ', $($GUIlogpath) -Color DarkYellow, DarkRed -ShowTime
        $script:LoggingEnabled = $false
        Stop-Transcript
        . (Get-Item $GUIlogpath).FullName
        HideConsole
    }

    #endregion
    #region process csv file
    foreach ($main in ($config.mainmenu | Get-Unique -AsString)) {
        $tmpmenu = NMainMenu -Text $main
        $record = $config | Where-Object { $_.Mainmenu -like $main }
        foreach ($rec in $record) {
            [scriptblock]$clickAction = [scriptblock]::Create( "Invoke-Action -control `$_ -name `"$($rec.Name)`" -command `"$($rec.command)`" -arguments `"$(($rec|Select-Object -ExpandProperty arguments -ErrorAction SilentlyContinue) -replace '"' , '`"`"')`" -mode $($rec.Mode) -Window `"$($rec.Window)`" -RunAsUser `"$($rec.RunAsUser)`" -RunAsAdmin `"$($rec.RunAsAdmin)`"" )
            NMenuItem -Text $rec.Name -clickAction $clickAction -command $rec.command -MainMenu $tmpmenu
        }
    }
    #endregion
    #region Add-Entry
    
    $line = New-Object System.Windows.Forms.ToolStripMenuItem
    $line.Text = '___________________________'
    $line.add_click({
            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFile $($PSSysTrayConfigFile)}"""
            $Systray_Tool_Icon.Visible = $false
            Stop-Process $pid
        })

    $contextmenu.Items.Add($line)

    $EditConfigMenu = $contextmenu.Items.Add('Edit Config')
    $EditConfigMenu.Image = $Edit_Icon


    $Add_Entry = New-Object System.Windows.Forms.ToolStripMenuItem
    $Add_Entry.Image = $Edit_Icon
    $Add_Entry.Text = 'Edit Config'
    $Add_Entry.add_Click( {
            ShowConsole
            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile  -ExecutionPolicy bypass -command ""& {Edit-PSSysTrayConfig -PSSysTrayConfigFile $($PSSysTrayConfigFile) -execute }"" -wait"
            $Systray_Tool_Icon.Visible = $false
            Stop-Process $pid
            HideConsole
        })
    $EditConfigMenu.DropDownItems.Add($Add_Entry)
    #endregion
    #region add Menu_EnableLog button
    # $Menu_EnableLog = New-Object System.Windows.Forms.ToolStripMenuItem
    # $Menu_EnableLog.Image = $Edit_Icon
    # $Menu_EnableLog.Text = 'Enable Logging'
    # $Menu_EnableLog.add_Click( { EnableLogging })
    #$EditConfigMenu.DropDownItems.Add($Menu_EnableLog)
    #endregion
    #region add Menu_DisableLog button
    # $Menu_DisableLog = New-Object System.Windows.Forms.ToolStripMenuItem
    # $Menu_DisableLog.Image = $Edit_Icon
    # $Menu_DisableLog.Text = 'Disable Logging'
    # $Menu_DisableLog.add_Click( { DisableLogging })
    #$EditConfigMenu.DropDownItems.Add($Menu_DisableLog)
    #endregion
    #region add Menu_DisableLog button
    $Menu_OpenConfig = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_OpenConfig.Image = $Edit_Icon
    $Menu_OpenConfig.Text = 'Open Config File'
    $Menu_OpenConfig.add_Click( { . (Get-Item $PSSysTrayConfigFile).FullName })
    $EditConfigMenu.DropDownItems.Add($Menu_OpenConfig)
    #endregion
    #region add exit button
    $Menu_Exit = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_Exit.Image = $Exit_Icon
    $Menu_Exit.Text = 'Exit'
    $Menu_Exit.add_Click( {
            $Systray_Tool_Icon.Visible = $false
            [void][System.Windows.Forms.Application]::Exit($appContext)
            Stop-Process $pid
        })
    $contextmenu.Items.Add($Menu_Exit)
    #endregion
    #region Start GUI
    # Create an application context for it to all run within.
    # This helps with responsiveness, especially when clicking Exit.
    $Systray_Tool_Icon.ContextMenuStrip = $contextmenu
    HideConsole
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [void][System.Windows.Forms.Application]::Run($appContext)
    #endregion
} #end Function

 
Export-ModuleMember -Function Start-PSSysTray
#endregion
 
#endregion
 
