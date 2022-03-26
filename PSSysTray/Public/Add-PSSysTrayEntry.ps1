
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

.EXAMPLE
Add-PSSysTrayEntry

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
        $index = 0
        $mainmenulist = ($config.mainmenu | Get-Unique)
        $mainmenulist | ForEach-Object {
            Write-Color "$($index)) ",$_ -Color Yellow,Green
            $index++
        }
        Write-Color "n)","New Main Menu" -Color Yellow,Green
        $choose = Read-Host "Choose main menu"
        if ($choose.ToLower() -like "n"){$MainMenu = Read-Host "New Menu Name"}
        else {$MainMenu = $mainmenulist[$choose]}

        [void]$config.Add([PSCustomObject]@{
            MainMenu   = $MainMenu
            Name       = (Read-Host 'Name')
            Command    = (Read-Host 'Command')
            Arguments  = (Read-Host 'Arguments')
            Mode       = (Read-Host 'Mode')
            Window     = (Read-Host 'Window')
            RunAsAdmin = (Read-Host 'RunAsAdmin')
         })

          Rename-Item $PSSysTrayConfigFilePath -NewName "PSSysTrayConfig-addentry-$(Get-Date -Format yyyy.MM.dd_HH.mm).csv" -Force
          $notes | Out-File -FilePath $PSSysTrayConfigFilePath -NoClobber -Force
          $config | Sort-Object -Property MainMenu | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | Out-File -FilePath $PSSysTrayConfigFilePath -Append -NoClobber -Force
          Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoLogo -NoProfile -WindowStyle Hidden -ExecutionPolicy bypass -command ""& {Start-PSSysTray -PSSysTrayConfigFilePath $($PSSysTrayConfigFilePath)}"""
} #end Function
