Import-Module ActiveDirectory

#Add PS SnapIn for On-Premise Exchange 2010
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

# Sets HostedVoiceMail attribute in Lync for all users who did not have it previously set.
$mbxs = Get-remotemailbox | where-object {($_.ExchangeUserAccountControl -ne "AccountDisabled")}

#$OUs= “OU=***Endeavor Robotics Employees,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=***Endeavor Robotics Interns,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=**Contractors,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=**Employees,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=**Interns,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”

$users = $mbxs | ForEach-Object {get-aduser -Identity $_.samaccountname -Properties msExchUCVoiceMailSettings | where-object {($_.Enabled -eq $true) -and (!($_.msExchUCVoiceMailSettings -like "*"))}}
#$users = get-aduser rwhitlingum


$cred = Get-Credential
$so = New-PSSessionOption -SkipCNCheck:$true -SkipCACheck:$true -SkipRevocationCheck:$true
$session = New-PSSession -ConnectionURI “https://hq-lyncfe-02.wardrobe.irobot.com/OcsPowershell" -Credential $cred -SessionOption $so
Import-PsSession $session

$lyncenabled = $users | foreach-object {get-csuser $_.UserPrincipalName}
$lyncenabled | foreach-object {set-csuser $_.UserPrincipalName -HostedVoiceMail:$true}

$lyncenabled | foreach-object {get-csuser $_.UserPrincipalName } | Select Name, HostedVoiceMail | ft -AutoSize
