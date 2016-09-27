###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-22-2016
# EDIT    : 01-22-2016
# COMMENT : Second Sync of Attic to Stor-Simple
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$dir  =  "\\hq-nas-01\files$\files"

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
$NASItems = (Invoke-GenericMethod `
    -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
    -MethodName         EnumerateFileSystemEntryInfos `
    -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
    -MethodParameters   $dir, '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where-object {(($_.FullPath) -ne "\\hq-nas-01\files$\files\Projects") -and (($_.FullPath) -ne "\\hq-nas-01\files$\files\Departments") -and (($_.FullPath) -ne "\\hq-nas-01\files$\files\caseyjones") -and (($_.FullPath) -ne "\\hq-nas-01\files$\files\Arcon") -and (($_.FullPath) -ne "\\hq-nas-01\files$\files\Software1")}

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{
        $pathOld = $NASItem.FullPath
        $pathNew = $pathOld -replace '\\hq-nas-01', 'G:'
        $pathFinal = $pathNew.TrimStart("\")
        $filename = $NASItem.FileName
        Start-Job -Name "Attic 2nd Copy $pathOld" -ScriptBlock {
        robocopy $args[0] $args[1] /S /ZB /V /XO /E /COPYALL /DCOPY:T /R:0 /W:0 /FP /NS /NC /NDL /MT:100 /LOG+:"C:\Users\sd_ashuttleworth\Desktop\Test\Final\Data\2nd_Sync\ATTIC_Copy_2ndSync_$($args[2]).log"
        } -ArgumentList $pathOld, $pathFinal, $filename
}