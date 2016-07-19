###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 08-27-2015
# EDIT    : 
# COMMENT : This script moves old, stale computers from
#          certain OU(s) into the Unmanaged OU.
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
$path        = "\\HQ-SCCMFS-01\Packages\Scripts"
$logSuccess  = $path + "\moveComputersSuccess_v2.log"
$logFail     = $path + "\moveComputersFail_v2.log"
$date        = Get-Date
$Computers   = Get-ADComputer -SearchBase "OU=Disabled Workstations,OU=Unmanaged,DC=wardrobe,DC=irobot,DC=com" -Filter {Enabled -eq "true"}
$TargetOU    = "OU=Old Workstations,OU=Unmanaged,DC=wardrobe,DC=irobot,DC=com"


#----------------------------------------------------------
#FUNCTIONS
#----------------------------------------------------------

#Delete Logs Files if they already exist
If (Test-Path $logSuccess) {Remove-Item $logSuccess}
If (Test-Path $logFail) {Remove-Item $logFail}

#Move Computers
$Computers | ForEach-Object{
             try {Move-ADObject -Identity $_.DistinguishedName -TargetPath $TargetOU -Confirm:$false
                  Write-Output "Success: Computer account $($_.Name) has been moved successfully" | Out-File $logSuccess -append}
             catch {Write-Output "Error: Computer account $($_.Name) was unsucessfully moved" | Out-File $logFail -append}
                    }

#Count successful and failed items from respective log files
$measureSuccess  = If (Test-Path $logSuccess) {Import-Csv $logSuccess | Measure-Object}
$measureFail     = If (Test-Path $logFail) {Import-Csv $logFail | Measure-Object}

If (Test-Path $logSuccess) {Write-Host "Success: $($measureSuccess.Count)"}
If (Test-Path $logFail) {Write-Output "Failed: $($measureFail.Count)"}