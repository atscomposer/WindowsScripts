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
$log            = $path + "Endeavor_New-SMBSHARES.log"                     

#----------------------------------------------------------
# FUNCTIONS
#----------------------------------------------------------                        

function Grant-userFullRights {            
 [cmdletbinding()]            
 param(            
 [Parameter(Mandatory=$true)]            
 [string[]]$Files,            
 [Parameter(Mandatory=$true)]            
 [string]$UserName            
 )            
 $rule=new-object System.Security.AccessControl.FileSystemAccessRule ($UserName,"FullControl","Allow")            

 foreach($File in $Files) {            
  if(Test-Path $File) {            
   try {            
    $acl = Get-ACL -Path $File -ErrorAction stop            
    $acl.SetAccessRule($rule)            
    Set-ACL -Path $File -ACLObject $acl -ErrorAction stop            
    Write-Host "Successfully set permissions on $File"            
   } catch {            
    Write-Warning "$File : Failed to set perms. Details : $_"            
    Continue            
   }            
  } else {            
   Write-Warning "$File : No such file found"            
   Continue            
  }            
 }            
}
#----------------------------------------------------------
# IMPORT CSV
#----------------------------------------------------------

$CSV  = Import-Csv '\\hq-sccmfs-01\packages\Scripts\Adam''s Scripts\Attic\Endeavor_NSG2-CS_09_17_2015_04_15_56_PM.csv'

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
                          Unblock-SmbShareAccess -Name $_.Name -ScopeName EDR-ATTIC -AccountName "Endeavor Robotics Attic Access - Deny" -Confirm:$false}

                        