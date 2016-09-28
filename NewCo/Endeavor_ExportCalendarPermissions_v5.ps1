$outputfile="C:\Users\sd_Ashuttleworth\Desktop\20160908_CalendarRights_Endeavor_v10.csv"

$boxen = get-mailbox -OrganizationalUnit "OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
$output = @()
foreach ($box in $boxen) {
	$primarySMTP = $box.PrimarySmtpAddress
        $ID = "$($primarySMTP):\Calendar"
        $permissions = get-mailboxfolderpermission $ID
        foreach ( $perm in $permissions ) {
            $mailbox = $primarySMTP
            $granteduser = $perm.User
            $access = $perm.AccessRights
            $identity = $perm.Identity
            $valid = $perm.IsValid
            if ( $identity -ne "Anonymous" ) {
                $output += @($mailbox, $granteduser, $identity, $access, $valid) | % { 
					New-Object PSObject -Property @{
						Mailbox  		= $mailbox
						Identity 		= $identity
						GrantedUser		= $granteduser
						AccessRights	= $Access
						IsValid			= $valid
						}
					}
                #$output += $outstring 
			}
		}
}
#set-content $outputfile $output

$output | select @{Name="Mailbox";Expression={$_.Mailbox}},@{Name="Granted User";Expression={$_.granteduser}},@{Name="Identity";Expression={$_.identity}},@{Name="AccessRights";Expression={$_.AccessRights}},@{Name="Is Valid?";Expression={$_.valid}} | export-csv 'C:\Users\sd_Ashuttleworth\Desktop\20160908_CalendarRights_Endeavor_v14.csv'