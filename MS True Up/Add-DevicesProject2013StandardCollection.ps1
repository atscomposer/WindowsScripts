$projaddcsv = get-content -Path '\\hq-sccmfs-01\Packages\MS True Up\Project\Project_Replace.csv'

cd 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module .\ConfigurationManager.psd1
cd HQ1:

# Add Devices to Microsoft Project 2013 Standard Device Collection
Foreach ($computer in $projaddcsv) {Add-CMDeviceCollectionDirectMembershipRule -CollectionID HQ1000D7 -ResourceID $(get-cmdevice -Name $computer).ResourceID}