###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 08-05-2015
# EDIT    : 
# COMMENT : This script changes password for users in
#          certain users found in a CSV file.
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOAD ASSEMBLIES AND MODULES
#----------------------------------------------------------
Try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
Catch
{
  Write-Host "[ERROR]`t ActiveDirectory Module couldn't be loaded. Script will stop!"
  Exit 1
}

#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
$path     = "\\HQ-SCCMFS-01\Packages\Scripts\Change"
$log      = $path + "\change_v1.log"
$csv      = $path + "\PassChange.csv"
$date     = Get-Date
#----------------------------------------------------------
#START FUNCTIONS
#----------------------------------------------------------
Function Start-Commands
{
  Create-Users
}

Function Create-Users
{
 "Processing started (on " + $date + "): " | Out-File $log -append
  "--------------------------------------------" | Out-File $log -append

foreach($user in (import-Csv $csv))
{
    try {
        $ds = new-Object System.DirectoryServices.DirectorySearcher([ADSI]"","(&(objectcategory=user)(sAMAccountName=$($user.sAMAccountName)))")
        $usr = ($ds.Findone()).GetDirectoryEntry()
        $usr.SetPassword($user.Password)
        $usr.SetInfo()
        Write-Output "Setting Password for $($User.samAccountName) was successful" | Out-File $log -append
        }
    catch {
            Write-Output "Setting Password for $($User.samAccountName) failed" | Out-File $log -Append
          }
}

  "--------------------------------------------" + "`r`n" | Out-File $log -append
}

Write-Host "STARTED SCRIPT`r`n"
Start-Commands
Write-Host "STOPPED SCRIPT"