﻿Get-Mailbox -OrganizationalUnit "OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com" | Get-MailboxPermission | ?{!($_.User -match "NT AUTHORITY")} | Select User,Identity,@{Name="AccessRights";Expression={$_.AccessRights}},@{Name="IsInherited";Expression={$_.IsInherited}} | Export-csv C:\Users\sd_Ashuttleworth\Desktop\20160908_ExchPermExport_Endeavor_v2.csv