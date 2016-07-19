###############################
# Script Information
# Scrpt Name: setRoomPermissions
# Created By: Adam Shuttleworth
# Created: May 12, 2016
# Last Modified: May 12, 2016
# Version: 1.0
###############################

# Office 365 Admin Credentials
$CloudUsername = 'globaladmin@irbt.onmicrosoft.com'
$CloudPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$CloudCred = New-Object System.Management.Automation.PSCredential $CloudUsername, $CloudPassword
 
# Connect to Office 365
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $CloudCred -Authentication Basic -AllowRedirection
Import-PSSession $session -Prefix O365
#Connect-MsolService -Credential $CloudCred

#GUI for Choosing Function to Run (Add Delegate, Add Book In Policy, Remove Delegate)
#
#
#
#
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "Function to Perform"
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
    $objLabel.Text = "Function to Perform:"
    $objForm.Controls.Add($objLabel)

    $objFuncListBox = New-Object System.Windows.Forms.ListBox
    $objFuncListBox.Location = New-Object System.Drawing.Size(10,40)
    $objFuncListBox.Size = New-Object System.Drawing.Size(260,20)
    $objFuncListBox.Height = 80

    [void] $objFuncListBox.Items.Add("Add Calendar Resource Delegate")
    [void] $objFuncListBox.Items.Add("Add Calendar BookInPolicy")
    [void] $objFuncListBox.Items.Add("Remove Calendar Resource Delegate")
    [void] $objFuncListBox.Items.Add("Remove Calendar BookInPolicy")

    $objForm.Controls.Add($objFuncListBox)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()


#GUI for Choosing Room Resource
#
#
#
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "Select a Room"
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
    $objLabel.Text = "Room to Add Booking Permissions to:"
    $objForm.Controls.Add($objLabel)

    $objListBox = New-Object System.Windows.Forms.ListBox
    $objListBox.Location = New-Object System.Drawing.Size(10,40)
    $objListBox.Size = New-Object System.Drawing.Size(260,20)
    $objListBox.Height = 80

    $rooms = Get-O365Mailbox -RecipientTypeDetails RoomMailbox

    $rooms | ForEach-Object {
        [void] $objListBox.Items.Add($_.Name)
    }

    $objForm.Controls.Add($objListBox)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()

# Function to select which group to begin migration
#
#
#
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "Email Address of User or Group"
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
    $objLabel.Text = "Type Email Address of User or Group:"
    $objForm.Controls.Add($objLabel)

    $objTextBox = New-Object System.Windows.Forms.TextBox
    $objTextBox.Location = New-Object System.Drawing.Size(10,40)
    $objTextBox.Size = New-Object System.Drawing.Size(260,20)
    $objForm.Controls.Add($objTextBox)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()

#Set Permissions on Room Resource
#
#
#
$selectedFunc = $objFuncListBox.SelectedItem
$roomname = $objListBox.SelectedItem
$delegate = $objTextBox.Text


If ($selectedFunc -eq "Add Calendar Resource Delegate"){
   function Add-CalendarResourceDelegate {
        Param(
        $roomName
        , $newDelegate
        )
        $resourceDelegates = (Get-O365CalendarProcessing -Identity $roomName).ResourceDelegates
        $resourceDelegates += $newDelegate
        Set-O365CalendarProcessing -Identity $roomName -ResourceDelegates $resourceDelegates
    }

Add-CalendarResourceDelegate -roomName $roomname -newDelegate $delegate
}

If ($selectedFunc -eq "Remove Calendar Resource Delegate"){
    function Remove-CalendarResourceDelegate {
        Param(
        $roomName
        , $delegateToRemove
        )
        $resourceDelegates = (Get-O365CalendarProcessing -Identity $roomName).ResourceDelegates
        $delegateToRemoveIdentity = (Get-O365Mailbox $delegateToRemove).Identity
        $resourceDelegates.Remove($delegateToRemoveIdentity)
        Set-O365CalendarProcessing -Identity $roomName -ResourceDelegates $resourceDelegates
    }

Remove-CalendarResourceDelegate -roomName $roomname -delegateToRemove $delegate
}

If ($selectedFunc -eq "Add Calendar BookInPolicy"){
    function Add-CalendarBookInPolicy {
        Param(
        $roomName
        , $newDelegate
        )
        $bookInPolicy = (Get-O365CalendarProcessing -Identity $roomName).BookInPolicy
        $bookInPolicy += $newDelegate
        Set-O365CalendarProcessing -Identity $roomName -BookInPolicy $bookInPolicy
    }

Add-CalendarBookInPolicy -roomName $roomname -newDelegate $delegate

}

If ($selectedFunc -eq "Remove Calendar BookInPolicy"){
    function Remove-CalendarResourceDelegate {
        Param(
        $roomName
        , $delegateToRemove
        )
        $bookInPolicy = (Get-O365CalendarProcessing -Identity $roomName).BookInPolicy
        $delegateToRemoveIdentity = (Get-O365Mailbox $delegateToRemove).Identity
        $bookInPolicy.Remove($delegateToRemoveIdentity)
        Set-O365CalendarProcessing -Identity $roomName -ResourceDelegates $resourceDelegates
    }

Remove-CalendarResourceDelegate -roomName $roomname -delegateToRemove $delegate
}
