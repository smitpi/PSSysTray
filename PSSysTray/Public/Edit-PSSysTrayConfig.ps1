
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0b5731b0-afcd-4836-9548-7bfc6de21381

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
Created [08/08/2022_21:06] Initial Script Creating

.PRIVATEDATA

#>

#Requires -Module PSWriteColor

<#

.DESCRIPTION
 Edit the config File

#>


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
