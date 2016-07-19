###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-22-2015
# EDIT    : 10-09-2015
# COMMENT : Replaced gci cmdlets with AlphaFS .NET library
# VERSION : 3.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$path           = "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\"
$logInitial     = $path + "ATTIC_Copy_InitialCopy_160111.log"
$logSuccess     = $path + "HQ-NAS-01_Copy_Success_151230.log"
$logError       = $path + "HQ-NAS-01_Copy_Error_151230.log"
$logRestore     = $path + "HQ-NAS-01_Copy_Restore_151230.log"

#----------------------------------------------------------
# DIRECTORY VARIABLES (CHANGE AS NEEDED)
#----------------------------------------------------------

$dir1 = '\\hq-nas-01\files$\files\'
$dir2 = 'G:\files$\files\'

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------

robocopy $dir1 $dir2 /S /E /ZB /V /FP /XO /NP /ETA /DCOPY:T /COPYALL /R:0 /W:0 /LOG+:$logInitial

#----------------------------------------------------------
# IMPORT AlphaFS MODULE AND CALL FUNCTIONS
#----------------------------------------------------------
$ndpDirectory = 'hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'
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
# RESTORE ARCHIVED FILES FROM RESTORE FROM UNC-HT_HQ-NAS-01
#----------------------------------------------------------

## $archivedItems = get-childitem $dir2 -Recurse -File | where-object {($_.LastWriteTime) -eq "Tuesday, January 1, 1980 7:00:00 PM"}
$archivedItems = (Invoke-GenericMethod `
    -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
    -MethodName         EnumerateFileSystemEntryInfos `
    -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
    -MethodParameters   'E:\Files$\files\', '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Files, Recursive, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where-object {($_.LastModified) -eq "Tuesday, January 1, 1980 7:00:00 PM"}

Foreach ($archivedItem in $archivedItems){
        $pathOld = Split-path $archivedItem.FullPath
        $pathNew = $pathOld -replace 'E:', 'F:\UNC-NT_HQ-Nas-01'
        $restoredFilePath = $archivedItem.FullPath -replace 'E:', 'F:\UNC-NT_HQ-Nas-01'
        $newFileName = $archivedItem.FileName + ".old"   
        
        $startDate = Get-Date

        if (Test-Path $restoredFilePath){
            "STARTED (on " + $StartDate + "): " | Out-File $logSuccess -append
            "--------------------------------------------" | Out-File $logSuccess -append
            "$(get-date): [SUCCESS]`t $($archivedItem.FullPath) exists and will be copied. See Restore Log." + "`r`n" | Out-File $logSuccess -Append

            Robocopy $pathNew $pathOld $archivedItem.FileName /E /ZB /V /FP /NP /ETA /DCOPY:T /COPYALL /R:1 /W:3 /LOG+:$logRestore
                ## Check if file restore was successful
                ## 
                if ((gci $archivedItem.FullPath).length -ne "0"){
                    ## Rename file in Restore Directory
                    ##
                    Rename-Item -path $restoredFilePath -newname $newFileName 
                        ## Check to see if file rename was successful
                        ##
                        if (Test-Path ($restoredFilePath + ".old")) {
                            ## Output to Success Log
                            ##
                            "$(get-date): [SUCCESS]`t $($archivedItem.FullPath) filename has been changed in the restore directory" + "`r`n"| Out-File $logSuccess -Append
                            $endDateSuccess = Get-Date
                            "ENDED (on " + $endDateSuccess + ")" + "`r`n" | Out-File $logSuccess -append
                            "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                        }
                        else {
                            $restoreErrorDate = Get-Date
                            "--------------------------------------------" + "`r`n"| Out-File $logError -append
                            "$($restoreErrorDate): [ERROR]`t $($archivedItem.Filename) filename was NOT changed correctly" | Out-File $logError -Append
                            "--------------------------------------------" + "`r`n" | Out-File $logError -append
                            ## Output pointer in Success Log stating the restore process was not successful
                            ##
                            "--------------------------------------------" + "`r`n" | Out-File $logError -append
                            "$($restoreErrorDate): [ERROR]`t SEE ERROR LOG: Rename process has errored at $($archivedItem.FileName)" | Out-File $logSuccess -append
                            "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                        }
                }
                else {
                    ## Output to Error Log Error Message
                    ##
                    $restoreErrorDate = Get-Date
                    "--------------------------------------------" + "`r`n" | Out-File $logError -append
                    "$($restoreErrorDate): [ERROR]'t $($archivedItem.FileName) was NOT successfully restored.`r`n" | Out-File $logError -append
                    "--------------------------------------------" + "`r`n" | Out-File $logError -append
                    ## Output pointer in Success Log stating the restore process was not successful
                    ##
                    "--------------------------------------------" + "`r`n" | Out-File $logError -append
                    "$($restoreErrorDate): [ERROR]`t SEE ERROR LOG: Restore process has errored at $($archivedItem.FileName)" | Out-File $logSuccess -append
                    "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                }
            }## End of if statement
        else {
            $ErrorDate = Get-Date
            "--------------------------------------------" + "`r`n" | Out-File $logError -append
            "$($ErrorDate): [ERROR]`t $($archivedItem.FileName) does NOT exist on the Recovered drive.`r`n" | Out-File $logError -append
            "--------------------------------------------" + "`r`n" | Out-File $logError -append
            ## Output pointer in Success Log stating the restore process was not successful
            ##
            "--------------------------------------------" + "`r`n" | Out-File $logError -append
            "$($ErrorDate): [ERROR]`t SEE ERROR LOG: Restore process has errored at $($archivedItem.FileName). File does not exist." | Out-File $logSuccess -append
            "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
            }## End of else statement 
        }## End of Foreach



        
