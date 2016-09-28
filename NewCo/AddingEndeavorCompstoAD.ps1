Write-Host "Please enter your desired computer name: [Default $env:computername]:"
$computername = Read-Host
 
$renamecomputer = $true
if ($computername -eq "" -or $computername -eq $env:computername) { $computername = $env:computername; $renamecomputer = $false }
 
$ou = "OU=***Endeavor Workstations,OU=Workstations,OU=iRobot Computers,DC=wardrobe,DC=irobot,DC=com"
 
Write-Host "Adding $computername to the domain.  The computer will restart automatically."
Read-host "Press Enter to exit..."
Add-Computer -DomainName "wardrobe.irobot.com" -Credential $(Get-Credential) -OUPath $ou
if ($renamecomputer -eq $true) { Rename-Computer -NewName $computername -Force }
Restart-Computer