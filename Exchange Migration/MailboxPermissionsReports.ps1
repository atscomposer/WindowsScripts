#Import Modules
If((Get-Module ActiveDirectory) -eq $null){Import-Module ActiveDirectory}

#Add PS SnapIn for On-Premise Exchange 2010
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

$Mailboxes = Get-Mailbox -resultsize Unlimited
#$Mailboxes = Get-Mailbox -resultsize Unlimited | Where {$_.Database  -ne "Recycle")}

$Mailboxes | SELECT Name, Identity, Alias, @{Name="GrantSendOnBehalfTo";Expression={$_.GrantSendOnBehalfTo[0].ToString();};}, Database, HiddenFromAddressListsEnabled, ExchangeUserAccountControl, IsMailboxEnabled, IsResource, IsShared | Export-Csv C:\temp\Mailboxes.txt -notype

$temp = @();

Foreach($mailbox in $Mailboxes){
	$t = Get-MailboxFolderPermission -Identity ($mailbox.Identity.ToString() + ":\Calendar") | Where{$_.Identity.ToString() -ne "Default" -and $_.Identity.ToString() -ne "Anonymous"} | SELECT @{Name='Mailbox';Expression={$mailbox.Alias};}, RunspaceId, FolderName, User, @{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}}, Identity, IsValid;
	If($t -ne $null){$temp += $t}
}
$temp |export-csv -Path C:\Temp\Mailbox_CalendarPermissions.txt -NoType;

$temp = @();

Foreach($mailbox in $Mailboxes){
	$t = Get-MailboxFolderPermission -Identity ($mailbox.Identity.ToString() + ":\Inbox") | Where{$_.Identity.ToString() -ne "Default" -and $_.Identity.ToString() -ne "Anonymous"} | SELECT @{Name='Mailbox';Expression={$mailbox.Alias};}, RunspaceId, FolderName, User, @{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}}, Identity, IsValid;
	If($t -ne $null){$temp += $t}
}
$temp | Export-CSV -Path C:\Temp\Mailbox_InboxPermissions.txt -NoType;

$temp = @();

Foreach($mailbox in $Mailboxes){
	$t = Get-MailboxPermission -Identity $mailbox.Identity | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | SELECT Identity, User, @{Name='Access Rights';Expression={[string]::join(', ', $_.AccessRights)}};
	If($t -ne $null){$temp += $t}
}
$temp | Export-CSV -Path C:\Temp\Mailbox_FullAccess.txt -NoType;

$temp = @();

Foreach($mailbox in $Mailboxes){
	$t = Get-ADPermission -Identity $mailbox.DistinguishedName | where {$_.ExtendedRights -like “*Send-As*" -and $_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | SELECT Identity, User, @{Name='Extended Rights';Expression={[string]::join(', ', $_.ExtendedRights)}};
	If($t -ne $null){$temp += $t }
}

foreach($user in $temp){try{if((get-aduser ($user.user).toupper().Replace("WARDROBE\","")).Enabled){$t=$True}else{$t=$false}}catch{$t=$false};$user | Add-Member -MemberType NoteProperty -Name "UserStatus" -Value $t;}
$temp | Export-CSV -Path C:\Temp\Mailbox_SendAs.txt -NoType;

$temp = @();

