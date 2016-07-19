function get-DCs
{
 import-module ActiveDirectory
$ADForest = Get-ADForest
$ADForestDomainNamingMaster = $ADForest.DomainNamingMaster
$ADForestDomains = $ADForest.Domains
$ADForestSchemaMaster = $ADForest.SchemaMaster
$ADForestGlobalCatalogs = $ADForest.GlobalCatalogs
 $ADInfo = Get-ADDomain
$ADDomainDNSRoot = $ADInfo.DNSRoot
$ADDomainInfrastructureMaster = $ADInfo.InfrastructureMaster
$ADDomainPDCEmulator = $ADInfo.PDCEmulator
$ADDomainReadOnlyReplicaDirectoryServers = $ADInfo.ReadOnlyReplicaDirectoryServers
$ADDomainReplicaDirectoryServers = $ADInfo.ReplicaDirectoryServers
$ADDomainRIDMaster = $ADInfo.RIDMaster

ForEach ($Domain in $ADForestDomains)
 { ## OPEN ForEach Domain in ADForestDomains
   $DomainDCs = Get-ADDomainController -filter * -server $Domain
   ForEach ($DC in $DomainDCs)
    { ## OPEN ForEach DC in DomainDCs
      $DCName = $DC.HostName
      [array] $ForestDCs += $DC.HostName
     } ## CLOSE ForEach DC in DomainDCs
  } ## CLOSE ForEach Domain in ADForestDomains
$ForestDCsCount = $ForestDCs.count
 # Add all DC lists into $DomainControllers
$DomainControllers = $ForestDCs + $ADDomainReadOnlyReplicaDirectoryServers + $ADDomainReplicaDirectoryServers + $ADForestGlobalCatalogs
# Remove duplicate DCs from $DomainControllers
$DomainControllers = $DomainControllers | Select-Object -Unique
# Sort the $DomainControllers DC list
$DomainControllers = $DomainControllers | Sort-Object
}

# Start Function
get-DCs

# Gpupdate and change Security Evet Log Size on all DCs
foreach ($strcomputer in $DomainControllers)
{
Write-Host "Updating $($strcomputer.Name)"
gpupdate /force
Write-Host "Changing Security Event Log Maximum Size on $($strcomputer.Name)"
Limit-EventLog -LogName Security -ComputerName $strcomputer.Name -MaximumSize 128MB
}

# Check Log Sizes for All DCs
foreach ($strcomputer in $DomainControllers)
{
Write-Host "Log Sizes for $($strcomputer)"
Get-EventLog -List -ComputerName $strcomputer
Write-Host "-----------------------------------" + "r'n'"
}