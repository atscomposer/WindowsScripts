###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 10-20-2015
# EDIT    : 
# COMMENT : This script moves old, stale computers from
#          certain OU(s) into the Unmanaged OU.
#          Computers have not been logged into for 30 days.
# VERSION : 3.0
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
$path        = "\\HQ-SCCMFS-01\Packages\Scripts"
$logSuccess  = $path + "\moveCompsSuccess.log"
$logFail     = $path + "\moveCompsFail.log"
$date        = Get-Date
$Computers   = Get-ADComputer -SearchBase "OU=Workstations,OU=iRobot Computers,DC=wardrobe,DC=irobot,DC=com" -Filter {lastLogonDate -le "9/20/2015"} | where {$_.distinguishedName -notlike "*OU=Mac Workstations,OU=Workstations,OU=iRobot Computers,DC=wardrobe,DC=irobot,DC=com"}
$TargetOU    = "OU=Old Workstations,OU=Unmanaged,DC=wardrobe,DC=irobot,DC=com"


#----------------------------------------------------------
#FUNCTIONS
#----------------------------------------------------------

#Delete Log Files if they already exist
If (Test-Path $logSuccess) {Remove-Item $logSuccess}
If (Test-Path $logFail) {Remove-Item $logFail}

#Move Computers
$Computers | ForEach-Object{
             try {Move-ADObject -Identity $_.DistinguishedName -TargetPath $TargetOU -Confirm:$false
                  Write-Output "Success: Computer account $($_.Name) has been moved successfully" | Out-File $logSuccess -append}
             catch {Write-Output "Error: Computer account $($_.Name) was unsucessfully moved" | Out-File $logFail -append}
                    }


#Disable Computers in Old Workstations OU
$oldComputers   = Get-ADComputer -SearchBase $TargetOU -Filter *

$oldComputers | Foreach-object {
                try {Disable-ADAccount -Identity $_.DistinguishedName
                     Write-Output "The Computer $($_.Name) has been succssfully disabled" | Out-File $logSuccess -append}
                catch {Write-Output "Error: Computer account $($_.Name) was unsucessfuly disabled" | Out-File $logFail -append}
                }

#Enable Computers in Old Workstations OU **For Use Only to Reverse Changes**
#$oldComputers | Foreach-object {
#                try {Enable-ADAccount -Identity $_.DistinguishedName
#                     Write-Output "The Computer $($_.Name) has been succssfully enabled" | Out-File $logSuccess -append}
#                catch {Write-Output "Error: Computer account $($_.Name) was unsucessfuly enabled" | Out-File $logFail -append}
#                }
#

#Count successful and failed items from respective log files
$measureSuccess  = If (Test-Path $logSuccess) {Import-Csv $logSuccess | Measure-Object}
$measureFail     = If (Test-Path $logFail) {Import-Csv $logFail | Measure-Object}

If (Test-Path $logSuccess) {Write-Host "Success: $($measureSuccess.Count)"}
If (Test-Path $logFail) {Write-Output "Failed: $($measureFail.Count)"}