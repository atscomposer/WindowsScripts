CD ‘D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin’
import-module .\ConfigurationManager.psd1
CD HQ1:

$Schedule1 = New-CMSchedule -Start "04/25/2016 8:00 AM" -DayOfWeek Monday -RecurCount 1 

$groups = Get-ADGroup -SearchBase "OU=Exchange Migration Project,OU=*IT Use Only - Internal,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com" -Filter *| Where-Object {$_.Name -ne "O365 Migration Team"}

Foreach ($group in $groups) {

New-CMUserCollection -Name $($group.Name) -LimitingCollectionName "All Users and User Groups" -RefreshSchedule $Schedule1 -RefreshType Periodic

Add-CMUserCollectionQueryMembershipRule -CollectionName $($group.name) -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User     where SMS_R_User.UserGroupName = 'WARDROBE\\$($group.name)'" -RuleName $($group.name)

$collection = Get-CMUserCollection -Name $($group.name)

Move-CMObject -FolderPath "HQ1:\UserCollection\Office 2013 Deployment\SD Created Migration Collections" -ObjectId $collection.CollectionID

}