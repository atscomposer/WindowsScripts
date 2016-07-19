Import-Module ActiveDirectory

$ous = Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -eq "Disabled Users"}
#$ous = "OU=Disabled Users,OU="

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
