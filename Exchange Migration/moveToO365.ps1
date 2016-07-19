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

# Get Exchange Migration Groups from AD
$groups = @(Get-ADGroup -Filter * -SearchBase "OU=Exchange Migration Project,OU=*IT Use Only - Internal,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com" | Select-Object -ExpandProperty Name)

# Function to select which group to begin migration
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Select a Group"
$objForm.Size = New-Object System.Drawing.Size(300,200)
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter")
    {$x=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape")
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$objForm.Close()})
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
$objLabel.Text = "Select a Group to Migrate:"
$objForm.Controls.Add($objLabel)

$objListBox = New-Object System.Windows.Forms.ListBox
$objListBox.Location = New-Object System.Drawing.Size(10,40)
$objListBox.Size = New-Object System.Drawing.Size(260,20)
$objListBox.Height = 80

foreach ($group in $groups){
[void] $objListBox.Items.Add($group)}

$objForm.Controls.Add($objListBox)

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

# Migrate each MBs to O365 as an individual Migration Batch
$selectedgroup = $objListBox.SelectedItem
$users = Get-ADGroupMember -identity $selectedGroup | %{get-aduser $_ -Properties EmailAddress | select Name, SamAccountName, EmailAddress}
#$users = 'itest' | %{get-aduser $_ -Properties EmailAddress | select Name, SamAccountName, EmailAddress}

foreach ($user in $users){
    $user | select EmailAddress | Export-Csv "C:\Temp\ExchangeMigration\$($selectedgroup)_$($user.SamAccountName).csv" -NoTypeInformation
    Write-host "CSV for this user has been created in C:\Temp\ExchangeMigration"
    #New-O365MoveRequest -Remote -RemoteCredential $OnPremCred -RemoteHostName legacy.irobot.com -Identity $user.Samaccountname -BatchName $user.Name -TargetDeliveryDomain irbt.mail.onmicrosoft.com -BadItemLimit 15 -SuspendWhenReadyToComplete -verbose
    New-O365MigrationBatch -Name $user.Name -SourceEndpoint legacy.irobot.com -TargetDeliveryDomain irbt.mail.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("C:\Temp\ExchangeMigration\$($selectedgroup)_$($user.SamAccountName).csv")) -AllowUnknownColumnsInCsv:$true -AutoStart -NotificationEmails O365MigrationTeam@irobot.com
    if (Get-O365MigrationBatch -Identity $($user.Name)){Rename-Item -Path "C:\Temp\ExchangeMigration\$($selectedgroup)_$($user.SamAccountName).csv" -NewName "Started_$($selectedgroup)_$($user.SamAccountName).csv"}
}


Read-Host -Prompt "Press Enter to exit"
