$useraffinity = gwmi -Namespace root\ccm\policy\machine -Class ccm_useraffinity
$users = “IRBT”,"wardrobe\Domain Admins","wardrobe\CORP Service Desk Group"
$domain = $env:USERDOMAIN
foreach ($useraff in $useraffinity)
{ $users += (($useraff.ConsoleUser +"_install").substring(0,29))}

$adsi = [ADSI]“WinNT://./administrators,group”
$members = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4

New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = “Administrators”
 Members=$members
} | out-null

foreach ($user in $users)
{
    if ((([Array]$members) -contains $user) -eq $false)
    {
        try {$adsi.Add(“WinNT://$Domain/” + ($user -Replace (“$($domain)\\”,””)) + “,group”)}
        catch {$adsi.Add("WinNT://$user")}
    }
}

foreach ($user in $members)
{ 
    if ((([Array]$users) -contains $user) -eq $false)
    {
        try { $adsi.Remove(“WinNT://$Domain/” + ($useradm -Replace (“$($domain)\\”,””))) } 
catch { $adsi.Remove(“WinNT://$user”) }
    }
}