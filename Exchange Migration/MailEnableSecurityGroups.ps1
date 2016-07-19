#1. Get all mail-enabled users
#2. Get all Full Access, Send As, Send on Behalf
#3. Find out if permissions use group(s) or user(s)
#4. DID NOT DO -- If User(s), enumerate and create mail-enabled security group of user(s).  Once successfully created, add group to appropriate permission type and remove inidivdual users
#5. If group, check if mail-enabled, (a) if not, mail-enable; (b) if so, do nothing


#Add PS SnapIn for On-Premise Exchange 2010
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
import-module DirSync

$mbxs = Get-Mailbox | where-object {($_.IsMailboxEnabled -eq $True) -and ($_.OrganizationalUnit -ne "wardrobe.irobot.com/iRobot Users/***Endeavor") -and ($_.OrganizationalUnit -ne "wardrobe.irobot.com/iRobot Users/**Contractors") -and ($_.OrganizationalUnit -notlike "wardrobe.irobot.com/iRobot Users/**Employees*") -and ($_.OrganizationalUnit -ne "wardrobe.irobot.com/iRobot Users/**Interns") -and ($_.OrganizationalUnit -ne "wardrobe.irobot.com/iRobot Users/**Interns") -and ($_.OrganizationalUnit -ne "wardrobe.irobot.com/iRobot Users/**Vendors") -and ($_.OrganizationalUnit -ne "wardrobe.irobot.com/iRobot Users/*Application Owners") -and ($_.OrganizationalUnit -notlike "wardrobe.irobot.com/iRobot Users/*IT Use Only - Internal*")}

$mbxs | foreach-object {$permissions = Get-MailboxPermission $_ | where-object {($_.IsInherited -eq $False) -and ($_.User -notlike "IROBOT\*") -and ($_.user.tostring() -ne "NT Authority\SELF") -and ($_.user.tostring() -ne "WARDROBE\Domain Admins")}
                        $permissions | ForEach-Object {$group = Get-Group $_.User.RawIdentity -ErrorAction SilentlyContinue
                            if ($group -ne $null -and $group.GroupType -notlike "*Universal*") {set-group $group.name -Universal -ErrorAction SilentlyContinue
                                if ($group.name -ne $null) {Write-Output "$($Group.name) has been changed to Universal Type" | Out-file "C:\Users\sd_ashuttleworth\Desktop\Logs\MailEnableSecurityGroups.csv" -Append}
                            }
                            if ($group -ne $null -and $group.RecipientType -ne "MailUniversalSecurityGroup") {Enable-DistributionGroup -Identity $group.name -ErrorAction SilentlyContinue
                                if ($group.name -ne $null) {Write-Output "$($group.name) has been Mail-Enabled" | Out-file "C:\Users\sd_ashuttleworth\Desktop\Logs\MailEnableSecurityGroups.csv" -Append}
                                if ((Get-DistributionGroup -identity $group.name).hiddenfromaddressListsEnabled -eq $false) {Set-DistributionGroup $group.name -HiddenFromAddressListsEnabled:$True
                                    if ((Get-DistributionGroup -identity $group.name).hiddenfromaddressListsEnabled -eq $true) {Write-Output "$($group.name) has been hidden from any Address Lists" | Out-file "C:\Users\sd_ashuttleworth\Desktop\Logs\MailEnableSecurityGroups.csv" -Append}
                            }
                         }
                }
        }

#Force DirSync
Start-OnlineCoexistenceSync
