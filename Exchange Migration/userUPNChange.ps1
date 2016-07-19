Import-Module ActiveDirectory

# Modifies the UPN for all users that currently have wardroboe.irobot.com to irobot.com

$OUS = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com" | Where-Object {$_.Name -like "*Employees*" -or $_.Name -like "*Contractors*" -or $_.Name -like "*Interns*"}

$users = $OUs | foreach-object {get-aduser -Filter * -SearchBase $_.DistinguishedName | Where-Object {($_.UserPrincipalName -like "*wardrobe.irobot.com")}}
    if ($users.count -ge 1){
    Write-Host "$($users.count) user(s) have an incorrect UPN that will be corrected"}
    else {
    Write-Host "All users have the correct UPN"
    }
$users | ForEach-Object {set-aduser -identity $_ -UserPrincipalName "$($_.SamAccountName)@irobot.com"}