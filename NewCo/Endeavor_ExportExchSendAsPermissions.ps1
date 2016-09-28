$boxen = Get-Mailbox -OrganizationalUnit "OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com" 
$output = @()
foreach ($box in $boxen) {
	$primarySMTP = $box.PrimarySmtpAddress
	$permissions = $box | get-ADPermission | where {($_.ExtendedRights -like '*Send-As*') -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF")}
	foreach ( $perm in $permissions ) {
		$mailbox = $primarySMTP
		$granteduser = $perm.User
		$access = $perm.ExtendedRights
		$identity = $perm.Identity
		if ( $identity -ne "Anonymous" ) {
			$output += @($mailbox, $granteduser, $identity, $access) | % { 
				New-Object PSObject -Property @{
					Mailbox  		= $mailbox
					Identity 		= $identity
					GrantedUser		= $granteduser
					AccessRights	= $Access
				}
			} 
		}
	}
}

$output | select @{Name="Mailbox";Expression={$_.Mailbox}},@{Name="Granted User";Expression={$_.granteduser}},@{Name="Identity";Expression={$_.identity}},@{Name="AccessRights";Expression={$_.AccessRights}} | where {$_.AccessRights -ne $null}| export-csv "C:\Users\sd_Ashuttleworth\Desktop\20160914_ExchPermExportSendAs_Endeavor_v3.csv"
	
	
#Get-ADPermission  select @{Name="Mailbox";Expression={$_.Mailbox}},@{Name="Granted User";Expression={$_.granteduser}},@{Name="Identity";Expression={$_.identity}},@{Name="AccessRights";Expression={$_.AccessRights}},@{Name="Is Valid?";Expression={$_.valid}} | Export-csv C:\Users\sd_Ashuttleworth\Desktop\20160914_ExchPermExportSendAs_Endeavor.csv