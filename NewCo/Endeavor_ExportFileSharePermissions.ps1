###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 03-01-2016
# EDIT    : 03-01-2016
# COMMENT : Modify NTSF Permissions on Attic for the Endeavor Company
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$dir  =  "\\hq-san-01\endeavor"
$path = "C:\Users\sd_Ashuttleworth\Desktop\Endeavor\FinalPermissions"

#----------------------------------------------------------
# IMPORT AlphaFS MODULE AND CALL FUNCTIONS
#----------------------------------------------------------
Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NTFSSecurity\AlphaFS.dll"

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
# ENUMERATE FOLDERS FROM \\HQ-NAS-01\files$\files
#----------------------------------------------------------
$NASItems = (Invoke-GenericMethod `
    -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
    -MethodName         EnumerateFileSystemEntryInfos `
    -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
    -MethodParameters   $dir, '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) |  where {($_.Filename -eq "ProPricer") -or ($_.Filename -eq "19 Alpha Rd Chelmsford")}

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{ 
    $pathOld = $NASItems.FullPath
    $filename = $NASItem.FileName

    Start-Job -Name "EndeavorPermissions $pathold" -ScriptBlock {
        Import-Module NTFSSecurity
        #Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NTFSSecurity\AlphaFS.dll"
        #Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\AlphaFS.2.0.1\lib\net451\AlphaFS.dll"
        
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
      ## ENUMERATE ALL FOLDERS AND FILES
         $allItems = (Invoke-GenericMethod `
            -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
            -MethodName         EnumerateFileSystemEntryInfos `
            -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
            -MethodParameters   $dir, '*',
                                ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, Files, Recursive, ContinueOnException'),
                                ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath))
      ## FIND ALL PERMISSIONS FOR SPECIFIED USERS
        $allItems | Foreach-object {<#$permissions +=#> Get-NTFSAccess -Path $_.FullPath | export-csv "$path\$($filename)_permissions.csv" -Append
            }
    } -ArgumentList $path, $filename, $pathOld
}
    
    
    
    
    
    

<#    $pathNew = ($pathOld -replace '\\hq-nas-01', 'E:').TrimStart("\")
    $filename = $NASItem.FileName

    Start-Job -Name "Attic Copy $pathOld" -ScriptBlock {
        <#$archivedItems = (Invoke-GenericMethod `
        -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
        -MethodName         EnumerateFileSystemEntryInfos `
        -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
        -MethodParameters   $arg[1], '*',
                            ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Files, Recursive, ContinueOnException'),
                            ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where-object {($_.LastModified) -eq "Tuesday, January 1, 1980 7:00:00 PM"}

        $AIOriginalPath = $($archivedItems.FullPath) -replace 'E:', '\\hq-nas-01'
        $excludedFiles = "`"$(($archivedItems.Fullpath) -join '" "')`""

       robocopy $args[0] $args[1] /MIR /B /XO /COPYALL /DCOPY:T /R:0 /W:0 /FP /MT:100 /LOG+:"C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\SubsequentSyncs\$($args[2])\$($args[3])\ATTIC_Sync_$($args[4]).log"
        } -InitializationScript { 
        Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\AlphaFS.2.0.1\lib\net451\AlphaFS.dll"
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
      } -ArgumentList $pathOld, $pathNew, $date, $time, $filename
} #>