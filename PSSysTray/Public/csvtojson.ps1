$config = Get-Content $PSSysTrayConfigFile | Where-Object {$_ -notlike '##*'} | ConvertFrom-Csv -Delimiter '~'
$config | where {$_.mainmenu -like "ModuleBuild"} | select Name,Command,Arguments,Mode,Window,RunAsAdmin | ConvertTo-Json | Out-Clipboard
