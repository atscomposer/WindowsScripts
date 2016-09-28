$csv = get-content "\\hq-sccmfs-01\packages\Scripts\Adam's Scripts\Endeavor\Endeavor_Vendors_List.csv"

$users = $csv | ForEach-Object {Get-aduser -identity $_}

$users | ForEach-Object {Move-ADObject -Identity $_ -TargetPath "OU=***Endeavor Robotics Vendors,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}