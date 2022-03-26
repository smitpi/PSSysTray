
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

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Add an entry in the csv file 

#> 


<#
.SYNOPSIS
Add an entry in the csv file

.DESCRIPTION
Add an entry in the csv file

.PARAMETER PSSysTrayConfigFilePath
Path to the config file created by New-PSSysTrayConfigFile

.EXAMPLE
Add-PSSysTrayEntry -PSSysTrayConfigFilePath C:\temp\PSSysTrayConfig.csv

#>
Function Add-PSSysTrayEntry {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/PSSysTray/Add-PSSysTrayEntry")]
                 Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.csv') })]
        [string]$PSSysTrayConfigFilePath
    )


        [System.Collections.ArrayList]$config = @()
        $notes = Get-Content $PSSysTrayConfigFilePath | Where-Object {$_ -like '##*'}
        $config = Get-Content $PSSysTrayConfigFilePath | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter ';'
        function mainmenu {
            Write-Color "Choose the Main Menu:" -Color DarkRed -StartTab 1 -LinesBefore 2
            $index = 0
            $mainmenulist = ($config.mainmenu | Get-Unique)
            $mainmenulist | ForEach-Object {
                Write-Color "$($index)) ",$_ -Color Yellow,Green
                $index++
            }
            Write-Color "n)","New Main Menu" -Color Yellow,Green
            $choose = Read-Host "Answer"
            if ($choose.ToLower() -like "n"){$MainMenu = Read-Host "New Menu Name"}
            else {$MainMenu = $mainmenulist[$choose]}
            $MainMenu
        }
        function mode {
            Write-Color "Choose the mode:" -Color DarkRed -StartTab 1 -LinesBefore 2
            Write-Color "0) ","PowerShell Script file" -Color Yellow,Green
            Write-Color "1) ","PowerShell Command" -Color Yellow,Green
            Write-Color "2) ","Other Executable" -Color Yellow,Green
            $modechoose = Read-Host "Answer"

            switch ($modechoose)
            {
                '0' {$mode = "PSFile"}
                '1' {$mode = "PSCommand"}
                '2' {$mode = "Other"}
            }
                $mode
        }
        function window {
            Write-Color "Choose the window size:" -Color DarkRed -StartTab 1 -LinesBefore 2
            Write-Color "0) ","Hidden" -Color Yellow,Green
            Write-Color "1) ","Maximized" -Color Yellow,Green
            Write-Color "2) ","Normal" -Color Yellow,Green
            Write-Color "3) ","Minimized" -Color Yellow,Green
            $modechoose = Read-Host "Answer" 

            switch ($modechoose)
            {
                '0' {$Window = "Hidden"}
                '1' {$Window = "Maximized"}
                '2' {$Window = "Normal"}
                '3' {$Window = "Minimized"}
            }
                $Window
        }
        function RunAs {
            Write-Color "Run As Admin:" -Color DarkRed -StartTab 1 -LinesBefore 2
            Write-Color "0) ","Yes" -Color Yellow,Green
            Write-Color "1) ","No" -Color Yellow,Green
            $modechoose = Read-Host "Answer"
            switch ($modechoose)
            {
                '0' {$RunAs = "Yes"}
                '1' {$RunAs = "No"}
            }
                $RunAs
        }

        [void]$config.Add([PSCustomObject]@{
            MainMenu   = mainmenu
            Name       = (Read-Host 'New Entry Name')
            Command    = (Read-Host 'Path to .exe')
            Arguments  = (Read-Host 'Arguments for executable')
            Mode       = Mode
            Window     = window
            RunAsAdmin = RunAs
         })

          Rename-Item $PSSysTrayConfigFilePath -NewName "PSSysTrayConfig-addentry-$(Get-Date -Format yyyy.MM.dd_HH.mm).csv" -Force
          $notes | Out-File -FilePath $PSSysTrayConfigFilePath -NoClobber -Force
          $config | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFilePath -Append -NoClobber -Force
          Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFilePath $($PSSysTrayConfigFilePath)}"""
} #end Function
