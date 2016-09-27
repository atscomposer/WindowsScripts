###########################################################
# AUTHOR      : Adam Shuttleworth
# DATE        : 08-26-2016
# EDIT        : 08-26-2016
# COMMENT     : Script to create AD Groups for NTFS File Server Access/Permissions
# Description : 
# VERSION     : 1.0
###########################################################

# Import Modules
Import-Module ActiveDirectory

# Finds Active Node in File Server Failover Cluster
$activenode = Get-WmiObject -Class Win32_computersystem -ComputerName hq-fs-01 | Select-Object -ExpandProperty Name

# Finds all Share on the Attic Client Access Point, checks if AD groups exist, and, if not, create them in appropriate AD OU
$attic = Invoke-Command -ComputerName $activenode -ScriptBlock {
    Get-smbshare -ScopeName attic | where {$_.Name -ne "E$" -or $_.Name -ne "Attic-New"}}

foreach ($i in $attic){
    #Test if AD Groups exist
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_ReadOnly"
    try {Get-adgroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Read Only Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_Modify"
    try {Get-ADGroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Modify Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_FullControl"
    try {Get-ADGroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Full Control Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    }

# Finds all Share on the HQ-NAS-01 Client Access Point, checks if AD groups exist, and, if not, create them in appropriate AD OU
$hqNas01 = Invoke-Command -ComputerName $activenode -ScriptBlock {
    Get-smbshare -ScopeName HQ-NAS-01 | where {$_.Name -ne "E$" -or $_.Name -ne "Attic-New"}
}

foreach ($i in $hqNas01){
    #Test if AD Groups exist
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_ReadOnly"
    try {Get-adgroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Read Only Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_Modify"
    try {Get-ADGroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Modify Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_FullControl"
    try {Get-ADGroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Full Control Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    }

# Finds all Share on the Caseyjones Client Access Point, checks if AD groups exist, and, if not, create them in appropriate AD OU
$caseyjones = Invoke-Command -ComputerName $activenode -ScriptBlock {
    Get-smbshare -ScopeName caseyjones | where {$_.Name -ne "E$" -or $_.Name -ne "Attic-New"}
}
foreach ($i in $caseyjones){
    #Test if AD Groups exist
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_ReadOnly"
    try {Get-adgroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Read Only Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_Modify"
    try {Get-ADGroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Modify Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    $name = "$($i.ScopeName)-$($i.Name)_FSAccess_FullControl"
    try {Get-ADGroup $name}
    catch {New-ADGroup -Name $name -GroupScope Universal -Description "For Full Control Access to the File Share \\$($i.ScopeName)\$($i.Name)" -Path "OU=$($i.ScopeName),OU=Attic FS Access Groups,OU=Security Groups,OU=iRobot Users,DC=wardrobe,DC=irobot,DC=com"}
    }
