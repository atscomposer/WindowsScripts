###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 09-02-2016
# EDIT    : 09-02-2016
# COMMENT : Initial Copy of Endeavor to Tri-Core NAS
# VERSION : 1.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# DIRECTORY TO COPY FROM
#----------------------------------------------------------

$dir  =  "\\hq-san-01\endeavor\"

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
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where {($_.Filename -ne "lost+found") -and ($_.Filename -ne ".etc")}

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{
        $pathOld = $NASItem.FullPath
        $pathNew = $pathOld -replace '\\hq-san-01', '\10.70.2.230' 
        $filename = $NASItem.FileName
        Start-Job -Name "Attic 2nd Copy $pathOld" -ScriptBlock {
        $uncServer = "\\10.70.2.230"
        $username = "admin"
        $password = "admin"
        net use $uncServer $password /USER:$username 
         
        robocopy $args[0] $args[1] /MIR /B /XO /DCOPY:T /R:0 /W:0 /FP /MT:100 /LOG+:"C:\Users\sd_ashuttleworth\Desktop\Endeavor\FinalMove\Endeavor_Sync4_$($args[2]).log"
        } -ArgumentList $pathOld, $pathNew, $filename
}