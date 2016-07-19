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
$dir  =  "\\hq-nas-01\files$\files"
$path = "C:\Users\sd_Ashuttleworth\Desktop\EndeavorPermissions"

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
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | Where-Object {($_.Filename -eq "ArchiveTest") -or ($_.Filename -eq "Activities")} 

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{ 
    $pathOld = $NASItems.FullPath
    $filename = $NASItem.FileName
    $users = Get-ADGroupMember "Endeavor Robotics All" | where-object {$_.Name -eq "Tormane, Michael"}
    $users2 = (Get-ADUser ashuttleworth),(Get-ADUser sd_ashuttleworth)
 
    Start-Job -Name "EndeavorPermissions $pathold" -ScriptBlock {
      ## GET USER SID LIST
          $SIDs=(($args[3].SID).value -join ",")
      ## ENUMERATE ALL FOLDERS AND FILES
         $allItems = (Invoke-GenericMethod `
        -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
        -MethodName         EnumerateFileSystemEntryInfos `
        -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
        -MethodParameters   $args[2], '*',
                            ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Files, Folders, Recursive, ContinueOnException'),
                            ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath))
      ## FIND ALL PERMISSIONS FOR SPECIFIED USERS
        $allItems | Foreach-object {$permissions += Get-NTFSAccess -Path $_.FullPath -Account $SIDs | export-csv "$args[0]\$args[1]_permissions.csv" -Append
            }
     }-InitializationScript { 
        Import-Module NTFSSecurity
        Import-Module -Name "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NTFSSecurity\AlphaFS.dll"
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
    } -ArgumentList $path, $filename, $pathOld, $users2
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