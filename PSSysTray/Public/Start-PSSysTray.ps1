
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

.PARAMETER ConfigFilePath
Path to the config file created by New-PSSysTrayConfigFile

.EXAMPLE
Start-PSSysTray -ConfigFilePath C:\temp\PSSysTrayConfig.csv 

#>
Function Start-PSSysTray {
		[Cmdletbinding(SupportsShouldProcess = $true, HelpURI = "https://smitpi.github.io/PSSysTray/Start-PSSysTray")]	    
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

