###############################
# Script Information
# Scrpt Name: movetoO365_v2
# Created By: Adam Shuttleworth
# Created: April 28, 2016
# Last Modified: April 29, 2016
# Version: 2.0
###############################

# Import Modules
Import-Module ActiveDirectory
Import-Module MSOnline

# Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword

# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session -Prefix O365
Connect-MsolService -Credential $CloudCred

# Function to select which group to begin migration
function Get-Number(){
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Number of Users"
$objForm.Size = New-Object System.Drawing.Size(300,200)
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter")
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape")
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20)
$objLabel.Size = New-Object System.Drawing.Size(280,20)
$objLabel.Text = "Type number of users to Migrate:"
$objForm.Controls.Add($objLabel)

$objTextBox = New-Object System.Windows.Forms.TextBox
$objTextBox.Location = New-Object System.Drawing.Size(10,40)
$objTextBox.Size = New-Object System.Drawing.Size(260,20)
$objForm.Controls.Add($objTextBox)

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$objTextBox.Text
}

function Get-Username(){
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "User to be Migrated"
$objForm.Size = New-Object System.Drawing.Size(300,200)
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter")
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape")
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20)
$objLabel.Size = New-Object System.Drawing.Size(280,20)
$objLabel.Text = "Type the Username of the User to be Migrated:"
$objForm.Controls.Add($objLabel)

$objTextBox = New-Object System.Windows.Forms.TextBox
$objTextBox.Location = New-Object System.Drawing.Size(10,40)
$objTextBox.Size = New-Object System.Drawing.Size(260,20)
$objForm.Controls.Add($objTextBox)

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$objTextBox.Text
}

# Get current User invoking script
$invokingUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name

# Migrate each MBs to O365 as an individual Migration Batch
$number = Get-Number

$i=0
for ($i=1; $i -le $number; $i++){
    $username = Get-Username
    $user = $(try {Get-ADUser -Identity $username -Properties EmailAddress | select Name, SamAccountName, EmailAddress} catch {$null})

    if ($user -ne $null){
        if ((Test-Path "C:\Temp\ExchangeMigration\$($user.SamAccountName).csv") -eq $TRUE){
            Write-host "CSV already exits in C:\Temp\ExchangeMigration"
            }
        else {
            $user | select EmailAddress | Export-Csv "C:\Temp\ExchangeMigration\$($user.SamAccountName).csv" -NoTypeInformation
            Write-host "CSV for $($user.SamAccountName) has been created in C:\Temp\ExchangeMigration"
            }
        New-O365MigrationBatch -Name $user.Name -SourceEndpoint legacy.irobot.com -TargetDeliveryDomain irbt.mail.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("C:\Temp\ExchangeMigration\$($user.SamAccountName).csv")) -AllowUnknownColumnsInCsv:$true -AutoStart -NotificationEmails O365MigrationTeam@irobot.com
        $testBatchCreation = Get-O365MigrationBatch -Identity $($user.Name)
            if ($testBatchCreation -ne $null){
                Remove-Item -Path "C:\Temp\ExchangeMigration\$($user.SamAccountName).csv"
                "$(get-date): O365 Migration has been started for $($username) by $($invokingUser)" | out-file "C:\Temp\ExchangeMigration\O365MigrationLog.log" -append
                }
            else {
                Write-Host "[ERROR]: No Migration Batch was created for $($user.SamaccountName)" -BackgroundColor "Red" -ForegroundColor "White"
                }
        }
    else {
        Write-Host "[ERROR]: $($username) does not exist in AD or username was spelled wrong" -BackgroundColor "Red" -ForegroundColor "White"
        }
    $user = $null
    $username = $null
}

Read-Host -Prompt "Press Enter to exit"
