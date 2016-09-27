###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-26-2016
# EDIT    : 09-26-2016
# COMMENT : Initial Copy of sahre from pas-vnx-01 to pas-san-01
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# DIRECTORY TO COPY FROM
#----------------------------------------------------------

$dir  =  "\\pas-vnx-01\C$"

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
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where {<#($_.Filename -eq "DLO") -or #>($_.Filename -eq "Creo") -or ($_.Filename -eq "Software")}

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{
        $pathOld = $NASItem.FullPath
        $pathNew = $pathOld -replace '\\pas-vnx-01', '\pas-san-01' 
        $pathFinal = $pathNew.TrimStart("\")
        $filename = $NASItem.FileName
        Start-Job -Name "PAS VNX Initial Copy $pathOld" -ScriptBlock {         
        robocopy $args[0] $args[1] /S /B /E /XO /DCOPY:T /R:0 /W:0 /NS /NC /NDL /MT:100 /LOG+:"C:\Users\sd_ashuttleworth\Desktop\PAS\PAS_VNX_Initial_Copy_$($args[2]).log"
        } -ArgumentList $pathOld, $pathNew, $filename
}