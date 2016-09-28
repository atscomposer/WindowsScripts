$dbs = "Corp1","Corp2","Corp3","Corp4","Corp5","Corp7","Office 365 - Rehyrdation"
$users = $dbs | ForEach-Object {Get-Mailbox -Database $_}
$users | set-mailbox -AddressBookPolicy "iRobot Address Book Policy"

$OU = "OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
$mbxs = get-mailbox -OrganizationalUnit $OU
$mbxs | where {($_.Database -ne "G&I1") -and ($_.database -ne "G&I2")} | foreach-object {New-MoveRequest -Identity $_.alias -TargetDatabase "G&I1" -SuspendWhenReadyToComplete}

$dbs = "G&I1","G&I2"
$users = $dbs | ForEach-Object {Get-Mailbox -Database $_}
$users | set-mailbox -AddressBookPolicy "Endeavor Address Book Policy"