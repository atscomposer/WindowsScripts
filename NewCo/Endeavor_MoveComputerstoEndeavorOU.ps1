$csv = import-csv "\\hq-sccmfs-01\packages\Scripts\Adam's Scripts\Endeavor\NewCoInventory.csv"

$assets = foreach ($comp in $csv) {'irbt-' + $($comp.assettag)}

$computers = foreach ($asset in $assets) {
        Try {
        Get-adcomputer -identity $asset -ErrorAction SilentlyContinue
        Write-Output $asset | out-file -append -filepath "C:\logs\success.log"}
        Catch {
        Write-Output $asset | out-file -append -filepath "C:\logs\failed.log"}
        }

$computers | ForEach-Object {Move-ADObject -Identity $_ -TargetPath "OU=***Endeavor Workstations,OU=Workstations,OU=iRobot Computers,DC=wardrobe,DC=irobot,DC=com"}