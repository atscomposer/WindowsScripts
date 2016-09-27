#Add PS SnapIn for On-Premise Exchange 2010
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

#Get all groups into temp variable
$groups = Get-DistributionGroup -ResultSize Unlimited

#Export 1) ON-PREM export all distribution groups and a few settings
$groups | Select-Object RecipientTypeDetails,Name,Alias,DisplayName,PrimarySmtpAddress,@{name="SMTPDomain";expression={$_.PrimarySmtpAddress.Domain}},MemberJoinRestriction,MemberDepartRestriction,RequireSenderAuthenticationEnabled,@{Name="ManagedBy";Expression={$_.ManagedBy -join “;”}},@{name=”AcceptMessagesOnlyFrom”;expression={$_.AcceptMessagesOnlyFrom -join “;”}},@{name=”AcceptMessagesOnlyFromDLMembers”;expression={$_.AcceptMessagesOnlyFromDLMembers -join “;”}},@{name=”AcceptMessagesOnlyFromSendersOrMembers”;expression={$_.AcceptMessagesOnlyFromSendersOrMembers -join “;”}},@{name=”ModeratedBy”;expression={$_.ModeratedBy -join “;”}},@{name=”BypassModerationFromSendersOrMembers”;expression={$_.BypassModerationFromSendersOrMembers -join “;”}},@{Name="GrantSendOnBehalfTo";Expression={$_.GrantSendOnBehalfTo -join “;”}},ModerationEnabled,SendModerationNotifications,LegacyExchangeDN,@{Name="EmailAddresses";Expression={$_.EmailAddresses -join “;”}} | Export-Csv C:\temp\distributiongroups.csv -NoTypeInformation

#Export 2) ON-PREM export distribution groups’ smtp aliases
$groups | Get-DistributionGroup -ResultSize Unlimited | Select-Object RecipientTypeDetails,PrimarySmtpAddress -ExpandProperty emailaddresses | select RecipientTypeDetails,PrimarySmtpAddress, @{name="TYPE";expression={$_}} | Export-Csv C:\temp\distributiongroups-SMTPproxy.csv -NoTypeInformation

#Export 3) ON-PREM export all distribution groups and members (and member type)
$groups |% {$guid=$_.Guid;$GroupType=$_.RecipientTypeDetails;$Name=$_.Name;$SMTP=$_.PrimarySmtpAddress ;Get-DistributionGroupMember -Identity $guid.ToString() -ResultSize Unlimited | Select-Object @{name=”GroupType”;expression={$GroupType}},@{name=”Group”;expression={$name}},@{name=”GroupSMTP”;expression={$SMTP}},@{name="PrimarySMTPDomain";expression={$SMTP.Domain}},@{Label="Member";Expression={$_.Name}},@{Label="MemberSMTP";Expression={$_.PrimarySmtpAddress}},@{Label="MemberType";Expression={$_.RecipientTypeDetails}}} | Export-Csv C:\temp\distributiongroups-and-members.csv -NoTypeInformation