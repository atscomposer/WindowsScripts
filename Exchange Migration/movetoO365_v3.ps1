########################################################################################################
# Script Information
# Scrpt Name: movetoO365_v3
# Created By: Adam Shuttleworth
# Created: May 17, 2016
# Last Modified: May 17, 2016
# Description: Script to find all mailboxes in O365 Rehydration Datastore and create O365 Sync Batch Job
# Version: 3.0
########################################################################################################

#Add PS SnapIn for On-Premise Exchange 2010
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

# Import Modules
Import-Module MSOnline

# Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session -Prefix O365
Connect-MsolService -Credential $CloudCred

# Get Exchange Migration Groups from AD
$users = Get-Mailbox -database "Office 365 - Rehydration" | Select Name, Alias, UserPrincipalName

# Get current User invoking script
$invokingUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name

foreach ($user in $users){
    if ((Get-O365MigrationBatch -Identity $($user.Name) -erroraction SilentlyContinue) -ne $null){
        Write-Host "Migration Batch already exists for $($user.alias)"
        }
    else {
        if ((Test-Path "C:\Temp\ExchangeMigration\$($user.alias).csv") -eq $TRUE){
            Write-host "CSV already exists in C:\Temp\ExchangeMigration"
            }
        else {
            $user | select UserPrincipalName | Export-Csv "C:\Temp\ExchangeMigration\$($user.alias).csv" -NoTypeInformation
            Write-host "CSV for $($user.alias) has been created in C:\Temp\ExchangeMigration"
            }

        New-O365MigrationBatch -Name $user.Name -SourceEndpoint legacy.irobot.com -TargetDeliveryDomain irbt.mail.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("C:\Temp\ExchangeMigration\$($user.alias).csv")) -AllowUnknownColumnsInCsv:$true -AutoStart -NotificationEmails O365MigrationTeam@irobot.com
        $testBatchCreation = Get-O365MigrationBatch -Identity $($user.Name)
        if ($testBatchCreation -ne $null){
            Remove-Item -Path "C:\Temp\ExchangeMigration\$($user.alias).csv"
            "$(get-date): O365 Migration has been started for $($user.alias) by $($invokingUser)" | out-file "C:\Temp\ExchangeMigration\O365MigrationLog.log" -append
            }
        else {
            Write-Host "[ERROR]: No Migration Batch was created for $($user.alias)" -BackgroundColor "Red" -ForegroundColor "White"
            }
    }
}

Read-Host -Prompt "Press Enter to exit"
