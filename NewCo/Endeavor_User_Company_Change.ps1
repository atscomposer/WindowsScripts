$OUs = "OU=***Endeavor Robotics Employees,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com","OU=***Endeavor Robotics Install_Accounts,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com","OU=***Endeavor Robotics Interns,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"
$users = $OUs | ForEach-Object {Get-ADUser -Filter * -SearchBase $_}

$users | ForEach-Object {Set-ADUser -Identity $_.DistinguishedName -Company "EndeavAor Rogetbotics"}