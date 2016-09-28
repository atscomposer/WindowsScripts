###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-11-2016
# EDIT    : 01-11-2016
# COMMENT : Create SMB Shares on new Failover Cluster
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$path           = "\\hq-sccmfs-01\packages\Scripts\Adam's Scripts\Endeavor\Logs\"
$log            = $path + "Endeavor_DenyAccessto-iRobotShares.log"                     

#----------------------------------------------------------
# IMPORT CSV
#----------------------------------------------------------

$CSV  = Import-Csv '\\hq-sccmfs-01\packages\Scripts\Adam''s Scripts\Attic\NSG2-CS_09_17_2015_04_15_56_PM.csv'

#----------------------------------------------------------
# Modify Ownership of Directories (This is to allow for share creation)
# &
# Create SMB Shares
#----------------------------------------------------------
$csv| ForEach-Object {$path = "E:" + $_.Path
                         #$acl = get-ACL -Path $Path
                         #$acl.SetOwner([System.Security.Principal.NTAccount]"BUILTIN\Administrators")
                         #Set-Acl $path $acl
                         #Grant-userFullRights -Files $path -UserName "BUILTIN\Administrators"
                         <#if (!(Get-SmbShare $_.Name)){
                          Write-Host $path}}#>
                          Block-SmbShareAccess -Name $_.Name -ScopeName $_.CIFS_Servers -AccountName "Endeavor Robotics Attic Access - Deny" -Confirm:$false}

#Added All members of "DL-Endeavor-All" to "Endeavor Robotics Attic Access - Deny" as individual objects 
#Get-ADGroupMember -Identity "Endeavor Robotics Attic Access - Deny" -Recursive | Foreach-object {Add-ADGroupMember -Identity "Endeavor Robotics Attic Access - Deny" -Members $_.Samaccountname}