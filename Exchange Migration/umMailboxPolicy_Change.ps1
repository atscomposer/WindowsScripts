# Change UMMailbox Policy from Lync to Bedford Dial Plan for those who have it set incorrectly.  If not changed migration to O365 will fail.

#$users = Get-UMMailbox | select PrimarySMTPAddress, UMMailboxpolicy | where-object {$_.UMMailboxpolicy -eq "Lync Default Policy"}
$users = get-mailbox ashuttleworth


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

