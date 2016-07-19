###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-22-2015
# EDIT    : 09-23-2015
# COMMENT : 
# VERSION : 2.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$path           = "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Copy\"
$logInitial     = $path + "HQ-NAS-01_Copy_InitialCopy.log"
$logSuccess     = $path + "HQ-NAS-01_Copy_Success.log"
$logError       = $path + "HQ-NAS-01_Copy_Error.log"
$logRestore     = $path + "HQ-NAS-01_Copy_Restore.log"

#----------------------------------------------------------
# DIRECTORY VARIABLES (CHANGE AS NEEDED)
#----------------------------------------------------------

$dir1 = 'G:\files$\files\'
$dir2 = 'E:\files$\files\'

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------

robocopy $dir2 $dir1 /S /E /ZB /V /FP /NP /ETA /DCOPY:T /COPYALL /R:1 /W:1n /LOG+:$logInitial

#----------------------------------------------------------
# RESTORE ARCHIVED FILES FROM RESTORE FROM UNC-HT_HQ-NAS-01 /XA:0
#----------------------------------------------------------

$archivedItems = get-childitem $dir2 -Recurse -File | where-object {($_.LastWriteTime) -eq "Tuesday, January 1, 1980 7:00:00 PM"}

Foreach ($archivedItem in $archivedItems){
        $pathOld = $archivedItem.DirectoryName
        $pathNew = $archivedItem.DirectoryName -replace 'E:', 'F:\UNC-NT_HQ-Nas-01'
        $findRestoredFile = $archivedItem.FullName -replace 'E:', 'F:\UNC-NT_HQ-Nas-01'
        $newFileName = $archivedItem.Name + ".old"  
        $restorePath = $pathNew + "\" + $archivedItem.Name
        
        $startDate = Get-Date

        if (Test-Path $findRestoredFile){
            "STARTED (on " + $StartDate + "): " | Out-File $logSuccess -append
            "--------------------------------------------" | Out-File $logSuccess -append
            "$(get-date): [SUCCESS]`t $($archivedItem.FullName) exists and will be copied. See Restore Log." + "`r`n" | Out-File $logSuccess -Append

            Robocopy $pathNew $pathOld $archivedItem.FileName /E /ZB /V /FP /NP /ETA /DCOPY:T /COPYALL /R:1 /W:3 /LOG+:$logRestore
                ## Check if file restore was successful
                ## 
                if ((gci $archivedItem.FullName).length -ne "0"){
                    ## Rename file in Restore Directory
                    ##
                    Rename-Item -path $restorePath -newname $newFileName 
                        ## Check to see if file rename was successful
                        ##
                        if (Test-Path ($restorePath + ".old")) {
                            ## Output to Success Log
                            ##
                            "$(get-date): [SUCCESS]`t $($archivedItem.FullName) filename has been changed in the restore directory" + "`r`n"| Out-File $logSuccess -Append
                            $endDateSuccess = Get-Date
                            "ENDED (on " + $endDateSuccess + ")" + "`r`n" | Out-File $logSuccess -append
                            "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                        }
                        else {
                            $restoreErrorDate = Get-Date
                            "--------------------------------------------" + "`r`n"| Out-File $logError -append
                            "$($restoreErrorDate): [ERROR]`t $($archivedItem.Name) filename was NOT changed correctly" | Out-File $logError -Append
                            "--------------------------------------------" + "`r`n" | Out-File $logError -append
                            ## Output pointer in Success Log stating the restore process was not successful
                            ##
                            "--------------------------------------------" + "`r`n" | Out-File $logError -append
                            "$($restoreErrorDate): [ERROR]`t SEE ERROR LOG: Rename process has errored at $($archivedItem.Name)" | Out-File $logSuccess -append
                            "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                        }
                }
                else {
                    ## Output to Error Log Error Message
                    ##
                    $restoreErrorDate = Get-Date
                    "--------------------------------------------" + "`r`n" | Out-File $logError -append
                    "$($restoreErrorDate): [ERROR]'t $($archivedItem.Name) was NOT successfully restored.`r`n" | Out-File $logError -append
                    "--------------------------------------------" + "`r`n" | Out-File $logError -append
                    ## Output pointer in Success Log stating the restore process was not successful
                    ##
                    "--------------------------------------------" + "`r`n" | Out-File $logError -append
                    "$($restoreErrorDate): [ERROR]`t SEE ERROR LOG: Restore process has errored at $($archivedItem.Name)" | Out-File $logSuccess -append
                    "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
                }
            }## End of if statement
        else {
            $ErrorDate = Get-Date
            "--------------------------------------------" + "`r`n" | Out-File $logError -append
            "$($ErrorDate): [ERROR]`t $($archivedItem.Name) does NOT exist on the Recovered drive.`r`n" | Out-File $logError -append
            "--------------------------------------------" + "`r`n" | Out-File $logError -append
            ## Output pointer in Success Log stating the restore process was not successful
            ##
            "--------------------------------------------" + "`r`n" | Out-File $logError -append
            "$($ErrorDate): [ERROR]`t SEE ERROR LOG: Restore process has errored at $($archivedItem.Name). File does not exist." | Out-File $logSuccess -append
            "--------------------------------------------" + "`r`n" | Out-File $logSuccess -append
            }## End of else statement 
        }## End of Foreach



        
