###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-22-2016
# EDIT    : 01-22-2016
# COMMENT : Rehydrate archived files of File Server Attic
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
    -MethodParameters   "G:\files$\files", '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath))

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($SF in $SubFolders)
{   $NewDir = New-Item -Path "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\Restores\" -Name $($SF.Filename) -ItemType directory
    $SFFullPath     = $SF.FullPath
    $SFFileName     = $SF.FileName
    
    Start-Job -Name "Attic Restore $($SFFullPath)" -ScriptBlock {
        $path = "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\Restores\$($args[1])\"
        $logSuccess     = $path + "HQ-NAS-01_Copy_Success_$($args[1]).log"
        $logError       = $path + "HQ-NAS-01_Copy_Error_$($args[1]).log"
        $logRestore     = $path + "HQ-NAS-01_Copy_Restore_$($args[1]).log"
        $archivedItems = (Invoke-GenericMethod `
        -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
        -MethodName         EnumerateFileSystemEntryInfos `
        -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
        -MethodParameters   $args[0], '*',
                            ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Files, Recursive, ContinueOnException'),
                            ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where-object {($_.LastModified) -eq "Tuesday, January 1, 1980 7:00:00 PM"}
        Foreach ($AI in $archivedItems){
            $atticNewPath = Split-path $AI.FullPath
            $AtticRestorePath = $atticNewPath -replace [Regex]::Escape("G:\") , 'G:\UNC-NT_HQ-Nas-01\'
            $restoredFilePath = $AI.FullPath -replace [Regex]::Escape("G:\") , 'G:\UNC-NT_HQ-Nas-01\'
            $newFileName = $AI.FileName + ".moved"
            $startDate = Get-Date
            if (Test-Path $AtticRestorePath){
                "STARTED (on " + $StartDate + "): " | Out-File $logSuccess -append
                "--------------------------------------------" | Out-File $logSuccess -append
                "$(get-date): [SUCCESS]`t $($AI.FullPath) exists and will be copied. See Restore Log." + "`r`n" | Out-File $logSuccess -Append
                Robocopy $AtticRestorePath $atticNewPath $AI.FileName /V /FP /NP /DCOPY:T /COPYALL /R:0 /W:0 /MT:50 /LOG+:$logRestore
                    ## Check if file restore waslk successful
                    ## 
                    if ((gci $AI.FullPath).length -ne "0"){
                        ## Rename file in Restore Directory
                        ##
                        Rename-Item -path $restoredFilePath -newname $newFileName 
                            ## Check to see if file rename was successful
                            ##
                            if (Test-Path ($restoredFilePath + ".moved")) {
                                ## Output to Success Log
                                ##
                                "$(get-date): [SUCCESS]`t $($AI.FullPath) filename has been changed in the restore directory" + "`r`n"| Out-File $logSuccess -Append
                                $endDateSuccess = Get-Date
                                "ENDED (on " + $endDateSuccess + ")" + "`r`n" | Out-File $logSuccess -append
                                "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                            }## End of if statement
                            else {
                                $restoreErrorDate = Get-Date
                                "--------------------------------------------" + "`r`n"| Out-File $logError -append
                                "$($restoreErrorDate): [ERROR]`t $($AI.FullPath) filename was NOT changed correctly" | Out-File $logError -Append
                                "--------------------------------------------" + "`r`n" | Out-File $logError -append
                                ## Output pointer in Success Log stating the restore process was not successful
                                ##
                                "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                                "$($restoreErrorDate): [ERROR]`t SEE ERROR LOG: Rename process has errored at $($AI.FullPath)" | Out-File $logSuccess -append
                                "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                            }## End of else statement
                    }## End of if statement
                    else {
                        ## Output to Error Log Error Message
                        ##
                        $restoreErrorDate = Get-Date
                        "--------------------------------------------" + "`r`n" | Out-File $logError -append
                        "$($restoreErrorDate): [ERROR]'t $($AI.FullPath) was NOT successfully restored.`r`n" | Out-File $logError -append
                        "--------------------------------------------" + "`r`n" | Out-File $logError -append
                        ## Output pointer in Success Log stating the restore process was not successful
                        ##
                        "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                        "$($restoreErrorDate): [ERROR]`t SEE ERROR LOG: Restore process has errored at $($AI.FullPath)" | Out-File $logSuccess -append
                        "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                    }## End of else statement
                }## End of if statement
            else {
                $ErrorDate = Get-Date
                "--------------------------------------------" + "`r`n" | Out-File $logError -append
                "$($ErrorDate): [ERROR]`t $($AI.FullPath) does NOT exist on the Recovered drive.`r`n" | Out-File $logError -append
                "--------------------------------------------" + "`r`n" | Out-File $logError -append
                ## Output pointer in Success Log stating the restore process was not successful
                ##
                "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                "$($ErrorDate): [ERROR]`t SEE ERROR LOG: Restore process has errored at $($AI.FullPath). File does not exist." | Out-File $logSuccess -append
                "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
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