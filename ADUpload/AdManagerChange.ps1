
###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 08-18-2015
# EDIT    : 
# COMMENT : This script clears AD User's Manager field.
#           For use on all Disable User AD accounts
# VERSION : 1.0
###########################################################

#----------------------------------------------------------
# Import AD Module
#----------------------------------------------------------
Import-Module ActiveDirectory

#----------------------------------------------------------
# Script Variable (TO BE MODIFIED)
#----------------------------------------------------------
$ous = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -eq "Disabled Users"}
#$ous = "OU=Disabled Users,OU="

#----------------------------------------------------------
# Script (DO NOT MODIFY BELOW)
#----------------------------------------------------------
$disabledUsers = $ous | ForEach-Object {Get-ADUser -filter * -SearchBase $_.DistinguishedName}

"______________________________" | out-file C:\Temp\ADManagerInfo.txt -Append
"START: $(get-date)" | out-file C:\Temp\ADManagerInfo.txt -Append

foreach ($user in $disabledUsers) {
    $manager = (Get-ADUser -Identity $user.SamAccountName -Properties Manager).Manager
    if ($manager -ne $null){
        $managerName = Get-ADUser -Identity $manager | select SamAccountName -ExpandProperty SamAccountName
        "Name: " + $user.Name | out-file C:\Temp\ADManagerInfo.txt -Append
        "Domain Account: " + $user.SamAccountName | out-file C:\Temp\ADManagerInfo.txt -Append
        "Manager: " + $managerName | out-file C:\Temp\ADManagerInfo.txt -Append
        set-aduser -Identity $user.Samaccountname -Manager $null
        "Manager AD Attribute has been cleared" | Out-File C:\Temp\ADManagerInfo.txt -Append
        "-------------------------------" | Out-File C:\Temp\ADManagerInfo.txt -Append
        }
    else {
        "Name: " + $user.Name | out-file C:\Temp\ADManagerInfo.txt -Append
        "Domain Account: " + $user.SamAccountName | out-file C:\Temp\ADManagerInfo.txt -Append
        "Manager: No Manager Set" | out-file C:\Temp\ADManagerInfo.txt -Append
        "-------------------------------" | Out-File C:\Temp\ADManagerInfo.txt -Append
    }
}
"END: $(get-date)" | out-file C:\Temp\ADManagerInfo.txt -Append
"______________________________" | out-file C:\Temp\ADManagerInfo.txt -Append
