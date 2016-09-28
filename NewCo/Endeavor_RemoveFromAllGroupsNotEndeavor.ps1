Import-Module ActiveDirectory

#Choose Organizational Unit
$OUs = "OU=***Endeavor Robotics Employees,OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com","OU=***Endeavor Robotics Interns,OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com","OU=***Endeavor Robotics Contractors,OU=***Endeavor,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
#$OUs = "OU=Test,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
$Users = $OUs | ForEach-Object {Get-ADUser -filter * -SearchBase $_ -Properties MemberOf}

#$users = Get-ADUser -Identity medis -Properties MemberOf

$groupsFilter = get-content -LiteralPath "\\hq-sccmfs-01\Packages\Scripts\Adam's Scripts\Endeavor\Endeavor-DLs.csv"
$groupsFilter = "($($groupsFilter -join '|'))"
# $groupsFilter in this example is: (citrix_GateKeeper|barracuda_spam_alerts)

Foreach ($user in $users) {If(((Get-ADUser $user -Properties MemberOf).MemberOf) -match $groupsFilter){$user.memberof | Get-ADGroup | where {$_.name -notmatch $groupsfilter} | remove-adgroupmember -Members $user -confirm:$false}}