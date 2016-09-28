#$OU = "OU=***Endeavor Robotics Employees,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
#$users = $OU | ForEach-Object {get-mailbox -OrganizationalUnit $_}
$users = Get-Mailbox atest 

$users | ForEach-Object {Disable-UMMailbox -Identity $_.UserPrincipalName -Confirm:$FALSE
                         Start-Sleep -Seconds 3
                         Enable-UMMailbox -Identity $_.UserPrincipalName -UMMailboxPolicy "Bedford Dial Plan Default Policy"
                         $ext=(Get-UMMailbox $_.alias).extensions
                         write-host "These are the extensions $($ext)"
                         write-host "Email Addresses $($_.EmailAddresses)"
                         $newDefEUM="eum:$($ext[0].substring(0,4));phone-context=Lync.irobot.com"
                         $newLyncEUM="eum:$($_.alias)@irobot.com;phone-context=Lync.irobot.com"
                         $_.EmailAddresses +=  "$($newLyncEUM)","$($newDefEUM)"
                         Set-Mailbox $_.UserPrincipalname -EmailAddresses $_.EmailAddresses}