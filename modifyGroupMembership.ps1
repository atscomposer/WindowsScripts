###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-04-2015
# EDIT    : 
# COMMENT : This script removes defined users from the
#          SFTP users group.
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOAD ASSEMBLIES AND MODULES
#----------------------------------------------------------
Try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
Catch
{
  Write-Host "[ERROR]`t ActiveDirectory Module couldn't be loaded. Script will stop!"
  Exit 1
}

#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
$path        = "\\HQ-SCCMFS-01\Packages\Scripts\Adam's Scripts"
$finallog    = $path + "\modifyGroupMembership.log"
$date        = Get-Date
$Group       = Get-AdGroup -Identity "CN=SFTP Users,OU=SFTP-USERS,DC=wardrobe,DC=irobot,DC=com"
$Members     = Get-ADUser -Filter {Name -eq "Munich, Mario"}

#----------------------------------------------------------
#FUNCTIONS
#----------------------------------------------------------

Function Start-Commands
{
  Modify-Group
}

Function Modify-Group
{
 "Processing started (on " + $date + "): " | Out-File $finallog -append
  "--------------------------------------------" | Out-File $finallog -append

ForEach ($member in $Members) {
    try {
        Remove-ADGroupMember -Identity $Group.DistinguishedName -Members $member -Confirm:$false
        Write-Output "$($member.samAccountName) was successful removed from $($Group.Name)" | Out-File $finallog -append
        }
    catch {
            Write-Output "ERROR: $($member.samAccountName) was NOT successful removed from $($Group.Name)" | Out-File $finallog -Append
          }
}

  "--------------------------------------------" + "`r`n" | Out-File $finallog -append
}

Write-Host "STARTED SCRIPT`r`n"
Start-Commands
Write-Host "STOPPED SCRIPT"

#----------------------------------------------------------
#MAIL RESULTS
#----------------------------------------------------------

$logs = Get-Content $finallog
[string]$mailbody = ""
foreach ($log in $logs) 
    {
        $mailBody = $mailBody + $log + "`r`n"
    }

$MailSubject= "User Account Removed from $($Group)"
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "smtp.irobot.com"
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "netops@irobot.com"
$MailMessage.To.add("netops@irobot.com")
$MailMessage.IsBodyHtml = 0
$MailMessage.Subject = $MailSubject
$MailMessage.Body = $MailBody
$SmtpClient.Send($MailMessage)