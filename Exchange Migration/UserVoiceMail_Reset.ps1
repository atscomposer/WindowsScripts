# Sets HostedVoiceMail attribute in Lync for all users who did not have it previously set.
$OUs= “OU=***Endeavor Robotics Employees,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=***Endeavor Robotics Interns,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=**Contractors,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=**Employees,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”,“OU=**Interns,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com”

$users = $OUs | foreach-object {get-aduser -LDAPFilter "(msExchUCVoiceMailSettings=CSHostedVoiceMail=0)" -Searchbase $_ -Properties msExchUCVoicemailSettings}
#$users =get-aduser emoore

$cred = Get-Credential
$so = New-PSSessionOption -SkipCNCheck:$true -SkipCACheck:$true -SkipRevocationCheck:$true
$session = New-PSSession -ConnectionURI “https://hq-lyncfe-02.wardrobe.irobot.com/OcsPowershell" -Credential $cred -SessionOption $so
Import-PsSession $session

$users | foreach-object {set-csuser $_.UserPrincipalName -HostedVoiceMail:$null
                         get-csuser $_.UserPrincipalName | Select Name, HostedVoiceMail | Out-File "\\hq-sccmfs-01\Packages\Scripts\Adam's Scripts\Exchange Migration\Logs"   
                         }