#Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

#Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session -Prefix O365
Connect-MsolService -Credential $cloudCred

#Input User's UM Extension
$ext = Read-Host 'Type the 4-digit Extension to search in O365 UM Configurations'

#Get UM Enabled Mailboxes
$user = Get-O365UMMailbox | Where-Object {$_.Extensions -eq $ext}
Write-Host "$($user.Name) is enabled for UM with Extension $($ext)"
Write-Host "UM will be disabled for $($user.Name)"
Disable-O365UMMailbox -Identity "$($user.DisplayName)"

$check = (Get-O365UMMailbox -identity "$($User.DisplayName)").UMEnabled
if ($check -eq $false){
    Write-Host "[SUCCESS]: UM has been disabled for $($user.DisplayName)"
}
else{
    Write-Host "[ERROR]: UM has NOT been disabled for $($user.DisplayName)"
}
