#Import Modules required
#Note - the Script Requires PowerShell 3.0!
#Import-Module MSOnline

#Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

#Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session
Connect-MsolService -Credential $cloudCred

$OnPremAdmin=Get-Credential

New-MoveRequest –identity “CR-RPDR@wardrobe.irobot.com” -Remote -RemoteHostName “colo-cas-02.wardrobe.irobot.com” -RemoteCredential $OnPremAdmin -TargetDeliveryDomain “irbt.mail.onmicrosoft.com”
