###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-22-2015
# EDIT    : 01-26-2016
# COMMENT : Copy of V: drive to Z: drive on SP-DB-PRD01
# VERSION : 5.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# DIRECTORY TO COPY FROM
#----------------------------------------------------------

$dir  =  "V:\"

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
        $pathNew = $pathOld -replace 'V:', 'Z:'
        $pathFinal = $pathNew.TrimStart("\")
        $filename = $NASItem.FileName

        Start-Job -Name "SP DB Transfer Copy $pathOld" -ScriptBlock {
        robocopy $args[0] $args[1] /B /E /MIR /COPYALL /DCOPY:T /R:0 /W:0 /NS /NC /NDL /NFL /NJH /NJS /MT:50
        } -ArgumentList $pathOld, $pathFinal
}