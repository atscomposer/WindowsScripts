###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-22-2015
# EDIT    : 01-19-2016
# COMMENT : Initial Copy of Attic to Stor-Simple
# VERSION : 5.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$path           = "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\"
$logInitial     = $path + "ATTIC_Copy_InitialCopy_160119_Test.log"

$dir  =  "\\hq-nas-01\files$\files\Media"

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
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath))

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
    { 
        $pathOld = $NASItem.FullPath
        $pathNew = $pathOld -replace '\\hq-nas-01', 'G:'
        $pathFinal = $pathNew.TrimStart("\")
        $logfile =
        Start-Job -Name "Attic Copy $pathOld" -ScriptBlock {
        robocopy $args[0] $args[1] /E /COPYALL /DCOPY:T /R:0 /W:0 /FP /NS /NC /NDL /MT:100 /LOG+:"C:\Users\sd_ashuttleworth\Desktop\Test\Final\Data\Media\ATTIC-Media_Copy_InitialCopy_160125.log"
        } -ArgumentList $pathOld, $pathFinal
    }