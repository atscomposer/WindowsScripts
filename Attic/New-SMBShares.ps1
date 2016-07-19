###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-11-2016
# EDIT    : 01-11-2016
# COMMENT : Create SMB Shares on new Failover Cluster
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$path           = "C:\Users\sd_Ashuttleworth\Desktop\Test\Shares\"
$log            = $path + "New-SMBSHARES.log"

#----------------------------------------------------------
# IMPORT AlphaFS MODULE AND CALL FUNCTIONS
#----------------------------------------------------------
$ndpDirectory = 'hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP'
$v4Directory = "$ndpDirectory\v4\Full"

if (Test-Path "$ndpDirectory\v2.0.50727") {
    $version = Get-ItemProperty "$ndpDirectory\v2.0.50727" -name Version | select Version
    $version
}
elseif (Test-Path "$ndpDirectory\v3.0") {
    $version = Get-ItemProperty "$ndpDirectory\v3.0" -name Version | select Version
    $version
}
elseif (Test-Path "$ndpDirectory\v3.5") {
    $version = Get-ItemProperty "$ndpDirectory\v3.5" -name Version | select Version
    $version
}
elseif (Test-Path $v4Directory) {
    $version = Get-ItemProperty $v4Directory -name Version | select -expand Version
    $version
}

##$dotNetVersion = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
##Get-ItemProperty -name Version,Release -EA 0 |
##Where { $_.PSChildName -match '^(?!S)\p{L}'} |
##Select Version, Release, PSChildName 

if ($version -ge "4.5.1"){cd C:\Users\Public\AlphaFS.2.0.1\lib\net451}
elseif ($version -le "4.5.0"){cd C:\Users\Public\AlphaFS.2.0.1\lib\net45}
elseif ($version -match "4.0"){cd C:\Users\Public\AlphaFS.2.0.1\lib\net40}
elseif ($version -match "3.5"){cd C:\Users\Public\AlphaFS.2.0.1\lib\net35}

Import-Module -Name ".\AlphaFS.dll"

Function Invoke-GenericMethod {
    Param(
        $Instance,
        [String]$MethodName,
        [Type[]]$TypeParameters,
        [Object[]]$MethodParameters
    )

    [Collections.ArrayList]$Private:parameterTypes = @{}
    ForEach ($Private:paramType In $MethodParameters) { [Void]$parameterTypes.Add($paramType.GetType()) }

    $Private:method = $Instance.GetMethod($methodName, "Instance,Static,Public", $Null, $parameterTypes, $Null)

    If ($Null -eq $method) { Throw ('Method: [{0}] not found.' -f ($Instance.ToString() + '.' + $methodName)) }
    Else {
        $method = $method.MakeGenericMethod($TypeParameters)
        $method.Invoke($Instance, $MethodParameters)
    }
}

#----------------------------------------------------------
# Modify Ownership of Directories
# This is to allow for share creation
#----------------------------------------------------------

$items = (Invoke-GenericMethod `
    -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
    -MethodName         EnumerateFileSystemEntryInfos `
    -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
    -MethodParameters   'G:\Files$\files\', '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath))

$items | ForEach-Object { ($acl = get-ACL -Path $_.FullPath) | Out-File C:\Users\sd_Ashuttleworth\Desktop\Test\Shares\Folder_ACLs_List.csv -Append
                          if ($acl -ne "BUILTIN\Administrators") { $acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
                                                                   Set-Acl -Path $_.FullPath $acl
                                                                 }
                         }

#----------------------------------------------------------
# IMPORT CSV
#----------------------------------------------------------

$CSV  = Import-Csv \\hq-cifs-01\Users\sd_Ashuttleworth\Desktop\Test\Shares\NSG2-CS_09_17_2015_04_15_56_PM_v2.csv

#----------------------------------------------------------
# Create SMB Shares
#----------------------------------------------------------

$CSV | ForEach-Object { $Path = "G:" + $_.Path
                        New-SmbShare -Name $_.Name -ScopeName $_.CIFS_Servers -Path $Path }