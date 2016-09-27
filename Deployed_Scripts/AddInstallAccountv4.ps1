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
# Load Functions
#----------------------------------------------------------

Function Remove-LocalUser 
{ 
 <# 
   .Synopsis 
    This function deletes a local user  
   .Description 
    This function deletes a local user 
   .Example 
    Remove-LocalUser -userName "ed"  
    Removes a new local user named ed.  
   .Parameter ComputerName 
    The name of the computer upon which to delete the user 
   .Parameter UserName 
    The name of the user to delete 
   .Notes 
    NAME:  Remove-LocalUser 
    AUTHOR: ed wilson, msft 
    LASTEDIT: 06/29/2011 10:07:42 
    KEYWORDS: Local Account Management, Users 
    HSG: HSG-06-30-11 
   .Link 
     Http://www.ScriptingGuys.com/blog 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [string]$computerName = $env:ComputerName 
 ) 
 $User = [ADSI]"WinNT://$computerName" 
 $user.Delete("User",$userName) 
} #end function Remove-LocalUser

Function Set-LocalGroup 
{ 
  <# 
   .Synopsis 
    This function adds or removes a local user to a local group  
   .Description 
    This function adds or removes a local user to a local group 
   .Example 
    Set-LocalGroup -username "ed" -groupname "administrators" -add 
    Assigns the local user ed to the local administrators group 
   .Example 
    Set-LocalGroup -username "ed" -groupname "administrators" -remove 
    Removes the local user ed to the local administrators group 
   .Parameter username 
    The name of the local user 
   .Parameter groupname 
    The name of the local group 
   .Parameter ComputerName 
    The name of the computer 
   .Parameter add 
    causes function to add the user 
   .Parameter remove 
    causes the function to remove the user 
   .Notes 
    NAME:  Set-LocalGroup 
    AUTHOR: ed wilson, msft 
    LASTEDIT: 06/29/2011 10:23:53 
    KEYWORDS: Local Account Management, Users, Groups 
    HSG: HSG-06-30-11 
   .Link 
     Http://www.ScriptingGuys.com/blog 
 #Requires -Version 2.0 
 #> 
 [CmdletBinding()] 
 Param( 
  [Parameter(Position=0, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$userName, 
  [Parameter(Position=1, 
      Mandatory=$True, 
      ValueFromPipeline=$True)] 
  [string]$GroupName, 
  [string]$computerName = $env:ComputerName, 
  [Parameter(ParameterSetName='addUser')] 
  [switch]$add, 
  [Parameter(ParameterSetName='removeuser')] 
  [switch]$remove 
 ) 
 $group = [ADSI]"WinNT://$ComputerName/$GroupName,group" 
 if($add) 
  { 
   $group.add("WinNT://$ComputerName/$UserName") 
  } 
  if($remove) 
   { 
   $group.remove("WinNT://$ComputerName/$UserName") 
   } 
} #end function Set-LocalGroup 

#----------------------------------------------------------
# Start Preliminary Script
# - Delete all local install accounts
#----------------------------------------------------------

$Computername = $env:COMPUTERNAME

  $ADSIComp = [adsi]"WinNT://$Computername"

$colUsers = ($ADSIComp.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "User" -and $_.Name -like '*_install'})

foreach ($user in $colusers) {Remove-LocalUser -userName ($user.Name)}

#----------------------------------------------------------
# Script Variables
#----------------------------------------------------------

$useraffinity = gwmi -Namespace root\ccm\policy\machine -Class ccm_useraffinity
$users = "Administrator",“IRBT”,"wardrobe\Domain Admins","wardrobe\Local Machine Admin Services","wardrobe\CORP Service Desk Group"
$domain = $env:USERDOMAIN
$adsi = [ADSI]“WinNT://./administrators,group”
$members = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4

#----------------------------------------------------------
# Start Main Script
# - Add specific users to local administrators group
# - Restrict users in local administrators group
#----------------------------------------------------------

foreach ($useraff in $useraffinity){
        $sam = $useraff.ConsoleUser
        If ($sam.length -lt 21){
                $numberx = $sam.length
            }
        Else {$numberx = 21}
        
$sam12 = $sam.Substring( 0, $numberx)
$samfinal = $sam12 + "_install"
$users += $samfinal
}

foreach ($user in $members)
{
if (!($users -contains $user))
{ 
        try {$adsi.Remove(“WinNT://$Domain/” + ($user -Replace ("$($domain)\\","")) + “,group”)}
        catch {$adsi.remove("WinNT://$user")}
### Set-LocalGroup -username $user -groupname "administrators" -remove
}
}

New-Object PSObject -Property @{
 Computername = $env:COMPUTERNAME
 Group = “Administrators”
 Members=$members
} | out-null

#----------------------------------------------------------
# Script Check/Verficiation
#----------------------------------------------------------
$members2 = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4

foreach ($user in $users)
{
    if ((([Array]$members2) -contains $user) -eq $false)
    {
        try {$adsi.Add(“WinNT://$Domain/” + ($user -Replace ("$($domain)\\","")) + “,group”)}
        catch {$adsi.Add("WinNT://$user")}
    }
}

$membersfinal = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4

$adminusers = $true
foreach ($user in $users)
{
if (!($membersfinal -contains $user))
{ 
$adminusers = $false
break;
}
}

foreach ($user in $membersfinal)
{
if (!($users -contains $user))
{ 
$adminusers = $false
break;
}
}

write-host $adminusers