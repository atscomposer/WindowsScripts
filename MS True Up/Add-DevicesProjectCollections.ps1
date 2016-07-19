$projremovecsv = get-content -Path '\\hq-sccmfs-01\Packages\MS True Up\Project\Project_Remove.csv'
$projreplacecsv = get-content -Path '\\hq-sccmfs-01\Packages\MS True Up\Project\Project_Replace.csv'

cd 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module .\ConfigurationManager.psd1
cd HQ1:

Foreach ($computer in $projremovecsv) {Add-CMDeviceCollectionDirectMembershipRule -CollectionID HQ1000C7 -ResourceID $(get-cmdevice -Name $computer).ResourceID}

Foreach ($computer in $projreplacecsv) {Add-CMDeviceCollectionDirectMembershipRule -CollectionID HQ1000C8 -ResourceID $(get-cmdevice -Name $computer).ResourceID}