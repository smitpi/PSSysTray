`	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateScript( { $IsAdmin = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
				if ($IsAdmin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { $True }
				else { Throw 'Must be running an elevated prompt.' } })]
		[ValidateSet('Combine', 'Build')]
		[string]$Update
	)
    #$ModuleName = (Get-Item $PSScriptRoot).Name
    $ModuleName = (Get-Item .).Name
    $fullpath = "D:\SharedProfile\CloudStorage\Dropbox\#Profile\Documents\PowerShell\ProdModules\$ModuleName"
	if ($Update -like 'Build') {
		try {
             if (test-path (Join-Path $PSScriptRoot "\Output")) {Remove-Item (Join-Path $PSScriptRoot "\Output") -Force -Recurse -ErrorAction Stop}
			 if (test-path (Join-Path $PSScriptRoot "\docs")) {Remove-Item (Join-Path $PSScriptRoot "\docs") -Force -Recurse -ErrorAction Stop}
		} catch {Write-Warning "Cant delete files`nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}

        
		Set-PSProjectFiles -ModulePSM1 ((Get-ChildItem -Path "$PSScriptRoot\*\*.psm1")[0]).FullName -VersionBump Build -mkdocs gh-deploy -GitPush
	} else {
		Set-PSProjectFiles -ModulePSM1 ((Get-ChildItem -Path "$PSScriptRoot\*\*.psm1")[0]).FullName -VersionBum CombineOnly -mkdocs serve -GitPush
	}

	try {
		$newmod = ((Get-ChildItem -Directory (Join-Path $fullpath "\Output")) | Sort-Object -Property Name -Descending)[0]
		if (-not(test-path "$($env:ProgramFiles)\WindowsPowerShell\Modules\$($ModuleName)")) {New-Item "$($env:ProgramFiles)\WindowsPowerShell\Modules\$($ModuleName)" -ItemType Directory -Force | Out-Null}
        Get-ChildItem -Directory "C:\Program Files\WindowsPowerShell\Modules\$($ModuleName)" | Compress-Archive -DestinationPath "C:\Program Files\WindowsPowerShell\Modules\$($ModuleName)\$($ModuleName)-bck.zip" -Update
		Get-ChildItem -Directory "C:\Program Files\WindowsPowerShell\Modules\$($ModuleName)" | Remove-Item -Recurse -Force
		Copy-Item -Path $newmod.FullName -Destination "C:\Program Files\WindowsPowerShell\Modules\$($ModuleName)\" -Force -Recurse

        if (-not(test-path "\\dfnas\Profile\Utils\PSModules\$($ModuleName)")) {New-Item "\\dfnas\Profile\Utils\PSModules\$($ModuleName)" -ItemType Directory -Force | Out-Null}
        Get-ChildItem -Directory "\\dfnas\Profile\Utils\PSModules\$($ModuleName)" | Compress-Archive -DestinationPath "\\dfnas\Profile\Utils\PSModules\$($ModuleName)\$($ModuleName)-bck.zip" -Update
		Get-ChildItem -Directory "\\dfnas\Profile\Utils\PSModules\$($ModuleName)" | Remove-Item -Recurse -Force
		Copy-Item -Path $newmod.FullName -Destination "\\dfnas\Profile\Utils\PSModules\$($ModuleName)\" -Force -Recurse
	} catch {Write-Warning "Unable to copy the new module `nMessage:$($_.Exception.Message)`nItem:$($_.Exception.ItemName)"}
