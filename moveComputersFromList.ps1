Import-Module ActiveDirectory

$ComputersPath= Import-Csv -Path "\\psf\Home\Documents\Workbook1.csv"
$TargetOU = "OU=IT-Workstations,OU=Workstations,OU=iRobot Computers,DC=wardrobe,DC=irobot,DC=com"
foreach ($item in $ComputersPath){

    $computer = Get-ADComputer $item.CompName

    Move-ADObject -Identity $computer.DistinguishedName -TargetPath $TargetOU -Confirm:$false

    Write-Host Computer account $computer.Name has been moved successfully
	
   
		}