###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 08-18-2015
# EDIT    : 
# COMMENT : This script restricts the workstation local 
#           administrator group to specific user accounts
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# Script Variables
#----------------------------------------------------------

$useraffinity = gwmi -Namespace root\ccm\policy\machine -Class ccm_useraffinity
$domain = $env:USERDOMAIN
$adsi = [ADSI]“WinNT://./Remote Desktop Users,group”
$members = net localgroup "Remote Desktop Users" | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4

#----------------------------------------------------------
# Start Main Script
# - Add specific users to local Remote Desktop Users group
#
#----------------------------------------------------------

foreach ($useraff in $useraffinity)
{   $sam = $useraff.ConsoleUser
    if ((([Array]$members) -contains $sam) -eq $false)
    {
        $adsi.Add(“WinNT://$Domain/” + ($sam -Replace ("$($domain)\\","")) + “,group”)
    }
}

$membersfinal = net localgroup "Remote Desktop Users" | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4

$adminusers = $True
foreach ($useraff in $useraffinity)
{
if (!($membersfinal -contains $useraff.ConsoleUser))
{ 
$adminusers = $False
break;
}
}

write-host $adminusers