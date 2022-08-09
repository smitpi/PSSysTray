
<#PSScriptInfo

.VERSION 0.1.0

.GUID 1e155ada-a5ed-44a5-bec5-54c070479a4d

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
Created [22/03/2022_11:57] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 This function reads csv config file and creates the GUI in your system tray.

#>


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
    $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru

    
    
    
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

    function ShowConsole {
        $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 5)
    }
    function HideConsole {
        $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
    }
    Function Invoke-Action {
        Param (
            [string]$command,
            [string]$arguments,
            [string]$mode,
            [string]$Window,
            [string]$RunAsAdmin
        )
        [hashtable]$processArguments = @{
            'PassThru' = $true
            'FilePath' = $command
        }

        if ( $RunAsAdmin -like 'yes' ) { $processArguments.Add( 'Verb' , 'RunAs' )}
        if ( $Window -contains 'Hidden') { $processArguments.Add('WindowStyle' , 'Hidden') }
        if ( $Window -contains 'Normal') { $processArguments.Add('WindowStyle' , 'Normal') }
        if ( $Window -contains 'Maximized') { $processArguments.Add('WindowStyle' , 'Maximized') }
        if ( $Window -contains 'Minimized') { $processArguments.Add('WindowStyle' , 'Minimized') }

        if ($mode -eq 'PSFile') { $AddedArguments = "-NoLogo  -NoProfile -ExecutionPolicy Bypass -File `"$arguments`"" }
        if ($mode -eq 'PSCommand') { $AddedArguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -command `"& {$arguments}`"" }
        if (-not($mode -eq 'Other') -and $LoggingEnabled) {$AddedArguments = '-NoExit ' + $AddedArguments}

        if ($mode -eq 'Other') { $AddedArguments = $arguments}

        if (-not[string]::IsNullOrEmpty( $AddedArguments)) {$processArguments.Add( 'ArgumentList' , [Environment]::ExpandEnvironmentVariables( $AddedArguments)) }

        Write-Color 'Running the following:' -Color DarkYellow -ShowTime
        $processArguments.GetEnumerator().name | ForEach-Object {Write-Color ('{0,-15}:' -f "$($_)"), ('{0}' -f "$($processArguments.$($_))") -ForegroundColor Cyan, Green -ShowTime}

        try {
            Start-Process @processArguments
            Write-Color 'Process Completed' -ShowTime -Color DarkYellow
        } catch {
            $Text = $This.Text
            [System.Windows.Forms.MessageBox]::Show("Failed to launch $Text`n`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)") > $null
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
            [scriptblock]$clickAction = [scriptblock]::Create( "Invoke-Action -control `$_ -name `"$($rec.Name)`" -command `"$($rec.command)`" -arguments `"$(($rec|Select-Object -ExpandProperty arguments -ErrorAction SilentlyContinue) -replace '"' , '`"`"')`" -mode $($rec.Mode) -Window `"$($rec.Window)`" -RunAsAdmin `"$($rec.RunAsAdmin)`"" )
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
    $Menu_EnableLog = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_EnableLog.Image = $Edit_Icon
    $Menu_EnableLog.Text = 'Enable Logging'
    $Menu_EnableLog.add_Click( { EnableLogging })
    #$EditConfigMenu.DropDownItems.Add($Menu_EnableLog)
    #endregion
    #region add Menu_DisableLog button
    $Menu_DisableLog = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_DisableLog.Image = $Edit_Icon
    $Menu_DisableLog.Text = 'Disable Logging'
    $Menu_DisableLog.add_Click( { DisableLogging })
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

