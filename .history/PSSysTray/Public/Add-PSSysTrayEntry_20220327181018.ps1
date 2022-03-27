
<#PSScriptInfo

.VERSION 0.1.0

.GUID b7b36f14-21c8-4617-826e-52e643bd953a

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
Created [26/03/2022_15:49] Initial Script Creating

.PRIVATEDATA

#>


<#

.DESCRIPTION
 Add an entry in the csv file

#>

<#
.SYNOPSIS
Add an entry in the csv config file.

.DESCRIPTION
Add an entry in the csv config file.

.PARAMETER PSSysTrayConfigFile
Path to the config file created by New-PSSysTrayConfigFile

.EXAMPLE
An Add-PSSysTrayEntry -PSSysTrayConfigFile C:\temp\PSSysTrayConfig.csv

#>
Function Add-PSSysTrayEntry {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSSysTray/Add-PSSysTrayEntry')]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { if ((Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv')) { $true}
                            else {throw "Not a valid config file."} })]
        [System.IO.FileInfo]$PSSysTrayConfigFile,
        [switch]$Execute = $false
    )


    
    Rename-Item $PSSysTrayConfigFile -NewName "PSSysTrayConfig-addentry-$(Get-Date -Format yyyy.MM.dd_HH.mm).csv" -Force
    function mainmenu {
        Write-Color 'Choose the Main Menu:' -Color DarkRed -StartTab 1 -LinesBefore 2
        $index = 0
        $mainmenulist = ($config.mainmenu | Get-Unique)
        $mainmenulist | ForEach-Object {
            Write-Color "$($index)) ", $_ -Color Yellow, Green
            $index++
        }
        Write-Color 'n) ', 'New Main Menu' -Color Yellow, Green
        $choose = Read-Host 'Answer'
        if ($choose.ToLower() -like 'n') {$MainMenu = Read-Host 'New Menu Name'}
        else {$MainMenu = $mainmenulist[$choose]}
        $MainMenu
    }
    function mode {
        Write-Color 'Choose the mode:' -Color DarkRed -StartTab 1 -LinesBefore 2
        Write-Color '0) ', 'PowerShell Script file' -Color Yellow, Green
        Write-Color '1) ', 'PowerShell Command' -Color Yellow, Green
        Write-Color '2) ', 'Other Executable' -Color Yellow, Green
        $modechoose = Read-Host 'Answer'

        switch ($modechoose) {
            '0' {
                $mode = 'PSFile'
                $command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
                $arguments = read-host "Path to .ps1 file"
            }
            '1' {$mode = 'PSCommand'
                $command = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
                $arguments = Read-Host 'PowerShell command or scriptblock'

            }
            '2' {$mode = 'Other'
                $command = Read-Host "Path to executable"
                $arguments = Read-Host "Arguments for the executable"
                }
        }
        [PSCustomObject]@{
            mode = $mode
            command = $command
            arguments = $arguments
        }
    }
    function window {
        Write-Color 'Choose the window size:' -Color DarkRed -StartTab 1 -LinesBefore 2
        Write-Color '0) ', 'Hidden' -Color Yellow, Green
        Write-Color '1) ', 'Maximized' -Color Yellow, Green
        Write-Color '2) ', 'Normal' -Color Yellow, Green
        Write-Color '3) ', 'Minimized' -Color Yellow, Green
        $modechoose = Read-Host 'Answer'

        switch ($modechoose) {
            '0' {$Window = 'Hidden'}
            '1' {$Window = 'Maximized'}
            '2' {$Window = 'Normal'}
            '3' {$Window = 'Minimized'}
        }
        $Window
    }
    function RunAs {
        Write-Color 'Run As Admin:' -Color DarkRed -StartTab 1 -LinesBefore 2
        Write-Color '0) ', 'Yes' -Color Yellow, Green
        Write-Color '1) ', 'No' -Color Yellow, Green
        $modechoose = Read-Host 'Answer'
        switch ($modechoose) {
            '0' {$RunAs = 'Yes'}
            '1' {$RunAs = 'No'}
        }
        $RunAs
    }

$again = 'y'
do {
        [System.Collections.ArrayList]$config = @()
        $notes = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -like '##*'}
        $script:config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter ';'

    $mainmenu = mainmenu
    Write-Color 'The new item name:' -Color DarkRed -StartTab 1 -LinesBefore 2
    $name = Read-Host 'Answer'
    $cmd = mode
    $Window = window
    $RunAs = RunAs

    [void]$config.Add([PSCustomObject]@{
            MainMenu   = $mainmenu
            Name       = $name
            Command    = $cmd.command
            Arguments  = $cmd.arguments
            Mode       = $cmd.mode
            Window     = $Window
            RunAsAdmin = $RunAs
        })

        $notes | Out-File -FilePath $PSSysTrayConfigFile -NoClobber -Force
        $config.mainmenu | ForEach-Object {
            $main = $_
            $content = $config | Where-Object {$_.mainmenu -like $main}
            $config.Remove(

        }
        $config | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFile -Append -NoClobber -Force

        $again = Read-Host "Add More entries (y/n)"
    } while ($again.ToLower() -notlike "n")


    if ($Execute) {
            Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFile $($PSSysTrayConfigFile)}"""
    }
} #end Function
