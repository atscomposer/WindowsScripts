###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 04-07-2016
# EDIT    : 04-07-2016
# COMMENT : Find size of al archived files on Endeavor Share
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# IMPORT AlphaFS MODULE AND CALL FUNCTIONS
#----------------------------------------------------------
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

#----------------------------------------------------------
# RESTORE ARCHIVED FILES FROM RESTORE FROM UNC-HT_HQ-NAS-01
#----------------------------------------------------------
$SubFolders = (Invoke-GenericMethod `
    -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
    -MethodName         EnumerateFileSystemEntryInfos `
    -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
    -MethodParameters   "\\hq-san-01\endeavor", '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath))
#----------------------------------------------------------
# RESTORE ARCHIVED FILES FROM ATTIC and HQ-NAS-01
#----------------------------------------------------------
foreach ($SF in $SubFolders)
{   $SFFullPath     = $SF.FullPath
    $SFFileName     = $SF.FileName
    Start-Job -Name "Endeavor Restore $($SFFileName)" -ScriptBlock {
        $path = "C:\Users\sd_Ashuttleworth\Desktop\Endeavor\ArchiveFileSizing\"
        $logEnumerate     = $path + "Endeavor_Copy_Size2.csv"
        $logSizeError     = $path + "Endeavor_Copy_SizeError2.csv"
        $archivedItems = (Invoke-GenericMethod `
        -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
        -MethodName         EnumerateFileSystemEntryInfos `
        -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
        -MethodParameters   $args[0], '*',
                            ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Files, Recursive, ContinueOnException'),
                            ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where-object {($_.LastModified) -eq "Tuesday, January 1, 1980 7:00:00 PM"}
        
        # Start Timestamp Logs
        $startDate = Get-Date
        #"STARTED (on " + $StartDate + "): " | Out-File $logSizeError -append
        #"STARTED (on " + $StartDate + "): " | export-csv $logEnumerate -append

        # Restore Archived Files
        Foreach ($AI in $archivedItems){
            $atticNewPath = Split-path $AI.FullPath
            $AtticRestorePath = $atticNewPath -replace [Regex]::Escape("\\HQ-SAN-01\Endeavor\") , '\\HQ-CIFS-01\Attic-Restore\'
            $restoredFilePath = $AI.FullPath -replace [Regex]::Escape("\\HQ-SAN-01\Endeavor\") , '\\HQ-CIFS-01\Attic-Restore\'
            #$newFileName = $AI.FileName + ".moved"

            # Enumerate and find size of all archived files                    
            if (Test-Path $restoredFilePath){
                [Alphaleonis.Win32.Filesystem.File]::GetFileSystemEntryInfo($restoredFilePath) | select FullPath, FileSize | Export-Csv $logEnumerate -append
                }
            else { 
                $ErrorDate = Get-Date
                "--------------------------------------------" | Out-File $logSzieError -append
                "$($ErrorDate): [ERROR]`t $($AI.FullPath) does NOT exist on the Recovered drive." | Out-File $logSizeError -append
                } 
        }
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
      } -ArgumentList $SFFullPath, $SFFileName
 }