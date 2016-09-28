########################################
##  Remove endeavorrobotics.com SMTP Addresses from Endeavor Mailboxes      
##  Created By: 9/23/2016 - Adam Shuttleworth            
########################################

#Add PS SnapIn for On-Premise Exchange 2010
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

#Remove All Endeavor Email Address Policies
$policies=Get-EmailAddressPolicy | where {$_.Name -like 'Endeavor*'}

foreach ($policy in $policies){
    Remove-EmailAddressPolicy -Identity $policy
}

Update-EmailAddressPolicy -Identity "Default Policy"
 
## Lookup All Endeavor Mailboxes from AD
$mailboxes=Get-Mailbox -OrganizationalUnit "OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
 
## Set Out of Office Message
Foreach ($user in $mailboxes)
{
    Set-Mailbox $user -EmailAddresses @{remove="$($user.alias)@endeavorrobotics.com"}
}
