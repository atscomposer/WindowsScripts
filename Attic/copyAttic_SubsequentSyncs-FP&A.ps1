###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-22-2016
# EDIT    : 01-22-2016
# COMMENT : Secondary Syncs of Attic to Stor-Simple
# VERSION : 2.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$dir  =  "\\attic\Departments\Accounting"

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
# 
#----------------------------------------------------------
$NASItems = (Invoke-GenericMethod `
    -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
    -MethodName         EnumerateFileSystemEntryInfos `
    -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
    -MethodParameters   $dir, '*',
                        ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Folders, ContinueOnException'),
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | Where-Object {$_.Filename -eq "FP&A"}

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{ 
    $pathOld = $NASItem.FullPath
    $pathNew = ($pathOld -replace 'attic', 'hq-san-01\endeavor')

    Start-Job -Name "Attic Copy $pathOld" -ScriptBlock {

       robocopy $args[0] $args[1] /E /B /COPYALL /DCOPY:T /R:0 /W:0 /FP /MT:100
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
      } -ArgumentList $pathOld, $pathNew
}