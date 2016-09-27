$useraffinity = gwmi -Namespace root\ccm\policy\machine -Class ccm_useraffinity
$users = "Administrator",“IRBT”,"wardrobe\Domain Admins","wardrobe\CORP Service Desk Group"
$domain = $env:USERDOMAIN
foreach ($useraff in $useraffinity)
{ $users += (($useraff.ConsoleUser +"_install").substring(0,29))}

$members = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4
New-Object PSObject -Property @{
Computername = $env:COMPUTERNAME
Group = “Administrators”
Members=$members
} | out-null

$adminusers = $true
foreach ($user in $users)
{
if (!($members -contains $user))
{ 
$adminusers = $false
break;
}
}

foreach ($user in $members)
{
if (!($users -contains $user))
{ 
$adminusers = $false
break;
}
}
write-host $adminusers