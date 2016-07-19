$projremovecsv = get-content -Path '\\HQ-SCCMFS-01\Packages\MS True Up\Visio\Visio_Remove_Group2.csv'
$projreplacecsv = get-content -Path '\\HQ-SCCMFS-01\Packages\MS True Up\Visio\Visio_Replace.csv'

cd 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module .\ConfigurationManager.psd1
cd HQ1:

Foreach ($computer in $projremovecsv) {Add-CMDeviceCollectionDirectMembershipRule -CollectionID HQ1000D2 -ResourceID $(get-cmdevice -Name $computer).ResourceID}

Foreach ($computer in $projreplacecsv) {Add-CMDeviceCollectionDirectMembershipRule -CollectionID HQ1000D2 -ResourceID $(get-cmdevice -Name $computer).ResourceID}