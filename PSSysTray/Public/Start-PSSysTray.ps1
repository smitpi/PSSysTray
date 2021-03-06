
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
 This function reads csv config file and creates the gui in your system tray.

#>


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

