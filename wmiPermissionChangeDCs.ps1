###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 10-13-2015
# EDIT    : 
# COMMENT : This script changes allows specified user with 
#           WMI Execute Method permissions to all DCs
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# Functions
#----------------------------------------------------------

function get-sid
{
Param (
 $DSIdentity
)
 $ID = new-object System.Security.Principal.NTAccount($DSIdentity)
 return $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
}

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


$sid = get-sid "wardrobe\svc_adaudit"
$SDDL = "A;;DC;;;$sid"

get-DCs

foreach ($strcomputer in $DomainControllers)
{   $security = Get-WmiObject -ComputerName $strcomputer -Namespace root/cimv2/Security -Class __SystemSecurity
    $converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
    $binarySD = @($null)
    $result = $security.PsBase.InvokeMethod("GetSD",$binarySD)
    $outsddl = $converter.BinarySDToSDDL($binarySD[0])
    $newSDDL = $outsddl.SDDL += "(" + $SDDL + ")"
    $WMIbinarySD = $converter.SDDLToBinarySD($newSDDL)
    $WMIconvertedPermissions = ,$WMIbinarySD.BinarySD
    $finalresult = $security.PsBase.InvokeMethod("SetSD",$WMIconvertedPermissions)
}