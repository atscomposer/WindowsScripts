###########################################################
# AUTHOR      : Adam Shuttleworth
# DATE        : 08-26-2016
# EDIT        : 08-26-2016
# COMMENT     : Script to create AD Groups for NTFS File Server Access/Permissions
# Description : 
# VERSION     : 1.0
###########################################################

# Import Modules (Requires NTFSSecurity @ https://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85) 
Import-Module NTFSSecurity

Param
(
	[Parameter(Mandatory=$false)]
	[Alias('Computer')][String[]]$ComputerName=$Env:COMPUTERNAME,

	[Parameter(Mandatory=$false)]
	[Alias('NTFS')][Switch]$NTFSPermission,
	
	[Parameter(Mandatory=$false)]
	[Alias('Cred')][System.Management.Automation.PsCredential]$Credential
)

$RecordErrorAction = $ErrorActionPreference
#change the error action temporarily
$ErrorActionPreference = "SilentlyContinue"

Function GetSharedFolderPermission($ComputerName)
{
	#test server connectivity
	$PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
	if($PingResult)
	{
		#check the credential whether trigger
		if($Credential)
		{
			$SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
			-ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
		}
		else
		{
			$SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
			-ComputerName $ComputerName -ErrorAction SilentlyContinue
		}
		
		foreach ($SharedFolderSec in $SharedFolderSecs) 
		{ 
		    $Objs = @() #define the empty array
			
	        $SecDescriptor = $SharedFolderSec.GetSecurityDescriptor()
	        foreach($DACL in $SecDescriptor.Descriptor.DACL)
			{  
				$DACLDomain = $DACL.Trustee.Domain
				$DACLName = $DACL.Trustee.Name
				if($DACLDomain -ne $null)
				{
	           		$UserName = "$DACLDomain\$DACLName"
				}
				else
				{
					$UserName = "$DACLName"
				}
				
				#customize the property
				$Properties = @{'ComputerName' = $ComputerName
								'ConnectionStatus' = "Success"
								'SharedFolderName' = $SharedFolderSec.Name
								'SecurityPrincipal' = $UserName
								'FileSystemRights' = [Security.AccessControl.FileSystemRights]`
								$($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])
								'AccessControlType' = [Security.AccessControl.AceType]$DACL.AceType}
				$SharedACLs = New-Object -TypeName PSObject -Property $Properties
				$Objs += $SharedACLs

	        }
			$Objs|Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal, `
			FileSystemRights,AccessControlType
	    }  
	}
	else
	{
		$Properties = @{'ComputerName' = $ComputerName
						'ConnectionStatus' = "Fail"
						'SharedFolderName' = "Not Available"
						'SecurityPrincipal' = "Not Available"
						'FileSystemRights' = "Not Available"
						'AccessControlType' = "Not Available"}
		$SharedACLs = New-Object -TypeName PSObject -Property $Properties
		$Objs += $SharedACLs
		$Objs|Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal, `
		FileSystemRights,AccessControlType
	}
}

Function GetSharedFolderNTFSPermission($ComputerName)
{
	#test server connectivity
	$PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
	if($PingResult)
	{
		#check the credential whether trigger
		if($Credential)
		{
			$SharedFolders = Get-WmiObject -Class Win32_Share `
			-ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
		}
		else
		{
			$SharedFolders = Get-WmiObject -Class Win32_Share `
			-ComputerName $ComputerName -ErrorAction SilentlyContinue
		}

		foreach($SharedFolder in $SharedFolders)
		{
			$Objs = @()
			
			$SharedFolderPath = [regex]::Escape($SharedFolder.Path)
			if($Credential)
			{	
				$SharedNTFSSecs = Get-WmiObject -Class Win32_LogicalFileSecuritySetting `
				-Filter "Path='$SharedFolderPath'" -ComputerName $ComputerName  -Credential $Credential
			}
			else
			{
				$SharedNTFSSecs = Get-WmiObject -Class Win32_LogicalFileSecuritySetting `
				-Filter "Path='$SharedFolderPath'" -ComputerName $ComputerName
			}
			
			$SecDescriptor = $SharedNTFSSecs.GetSecurityDescriptor()
			foreach($DACL in $SecDescriptor.Descriptor.DACL)
			{  
				$DACLDomain = $DACL.Trustee.Domain
				$DACLName = $DACL.Trustee.Name
				if($DACLDomain -ne $null)
				{
	           		$UserName = "$DACLDomain\$DACLName"
				}
				else
				{
					$UserName = "$DACLName"
				}
				
				#customize the property
				$Properties = @{'ComputerName' = $ComputerName
								'ConnectionStatus' = "Success"
								'SharedFolderName' = $SharedFolder.Name
								'SecurityPrincipal' = $UserName
								'FileSystemRights' = [Security.AccessControl.FileSystemRights]`
								$($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])
								'AccessControlType' = [Security.AccessControl.AceType]$DACL.AceType
								'AccessControlFalgs' = [Security.AccessControl.AceFlags]$DACL.AceFlags}
								
				$SharedNTFSACL = New-Object -TypeName PSObject -Property $Properties
	            $Objs += $SharedNTFSACL
	        }
			$Objs |Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights, `
			AccessControlType,AccessControlFalgs -Unique
		}
	}
	else
	{
		$Properties = @{'ComputerName' = $ComputerName
						'ConnectionStatus' = "Fail"
						'SharedFolderName' = "Not Available"
						'SecurityPrincipal' = "Not Available"
						'FileSystemRights' = "Not Available"
						'AccessControlType' = "Not Available"
						'AccessControlFalgs' = "Not Available"}
					
		$SharedNTFSACL = New-Object -TypeName PSObject -Property $Properties
	    $Objs += $SharedNTFSACL
		$Objs |Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights, `
		AccessControlType,AccessControlFalgs -Unique
	}
} 

# Finds Active Node in File Server Failover Cluster
$activenode = Get-WmiObject -Class Win32_computersystem -ComputerName hq-fs-01 | Select-Object -ExpandProperty Name

mkdir C:\Permissions

$ComputerName = "attic","hq-nas-01","caseyjones"

foreach ($CN in $ComputerName){
    if($NTFSPermission)
	{
		GetSharedFolderNTFSPermission -ComputerName $CN | Export-csv C:\FolderPermission\$($CN)_NTFSPermissions.csv
	}
	else
	{
		GetSharedFolderPermission -ComputerName $CN | Export-csv C:\FolderPermission\$($CN)_SharePermissions.csv
	}
}