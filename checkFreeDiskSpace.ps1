function Check-Diskspace {
param (
[parameter(Mandatory = $true)]
[string]$computer
)
$cred = Get-Credential
$DriveName1 = @{name=”DriveName”;Expression={$_.DeviceID+””}}
$TotalSpace = @{name=”Total Space”;expression = {($_.size/1GB).ToString(“0.00")+” GB"}}
$FreeSpace = @{name=”Free Space”;expression = {($_.FreeSpace/1GB).ToString(“0.00")+” GB”}}
gwmi -Class Win32_logicalDisk -filter “Drivetype=’3'” -computer $computer -credential $cred | Select $DriveName1, $TotalSpace, $FreeSpace | ft -auto
$cred = $null
}

$DomainDCs = Get-ADDomainController -filter *

foreach ($DomainDC in $DomainDCs) {Enter-PSSession -ComputerName $DomainDC.Name
                             Write-Host "Disk space for DC $($DomainDC.Name)"
                             fsutil volume diskfree C:
                             Exit-PSSession}

fsutil volume diskfree C: