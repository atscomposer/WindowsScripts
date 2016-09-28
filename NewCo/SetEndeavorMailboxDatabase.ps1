$OU = "OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
$mbxs = get-mailbox -OrganizationalUnit $OU
$mbxs | where {($_.Database -ne "G&I1") -and ($_.database -ne "G&I2")} | foreach-object {New-MoveRequest -Identity $_.alias -TargetDatabase "G&I1" -SuspendWhenReadyToComplete}