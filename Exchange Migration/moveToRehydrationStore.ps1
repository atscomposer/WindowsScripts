# Import Modules
Import-Module ActiveDirectory

# Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session -Prefix O365
Connect-O365MsolService -Credential $CloudCred

#$users = (Get-ADGroupMember -identity 'Exchange Migration POC - Group 1') | select -ExpandProperty SamAccountName
$users = 'itest'

foreach ($user in $users){
    New-MoveRequest -Identity $user -Remote -RemoteHostName colo-cas-02.wardrobe.irobot.com -TargetDeliveryDomain irbt.mail.onmicrosoft.com -RemoteCredential $CloudCred -BadItemLimit 15
}
