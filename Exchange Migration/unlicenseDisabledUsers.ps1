# Import Modules
Import-Module MSOnline

# Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword
 
# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session
Connect-MsolService -Credential $CloudCred

# Log File Location
$Log = "C:\Users\sd_ashuttleworth\Desktop\Logs\unlicenseDisabledUsers.txt"

$toDisable=$null
Foreach ($User in (Get-MsolUser -All))
{
    If (($User.BlockCredential -eq $true) -and ($User.IsLicensed -eq $true))
    {
    Write-Output "$(Get-Date) - $($User.UserPrincipalName) is disabled but is licensed" -ForegroundColor Red | out-file $Log -Append
    $toDisable += $user
    }
}

If ($toDisable -eq $null)
{
    Write-Output "$(Get-Date) - No disabled users are currently licensed in O365" | out-file $Log -Append
}

Foreach ($account in $toDisable)
{
    $AccountSKUs=Get-MsolAccountSku
    foreach ($license in $account.Licenses)
        {
        Set-MsolUserLicense -UserPrincipalName $account.UserPrincipalName -RemoveLicenses $license.AccountSKUID
        Write-Output "$(Get-Date) - $($license.AccountSKUID) has been removed from $($account.UserPrincipalName)" | out-file $Log -Append
        }
}
