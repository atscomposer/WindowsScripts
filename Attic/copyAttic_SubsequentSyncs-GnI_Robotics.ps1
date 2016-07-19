###########################################################
# AUTHOR  : Adam Shuttleworth
# DATE    : 01-22-2016
# EDIT    : 01-22-2016
# COMMENT : Secobdary Syncs of Attic to Stor-Simple
# VERSION : 2.0
###########################################################

# ERROR REPORTING ALL
Set-StrictMode -Version latest

#----------------------------------------------------------
# LOG FILES
#----------------------------------------------------------
$dir  =  "\\hq-nas-01\files$\files\Departments"

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
                        ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | Where-Object {$_.Filename -eq "GnI_Robotics"}

$date = Get-Date -UFormat "%y-%m-%d"
$time = Get-Date -UFormat "%H%M"

$dirExists = Test-Path "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\SubsequentSyncs\$($date)"
if($dirExists -eq $False) {mkdir "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\SubsequentSyncs\$($date)"}

$2nddirExists = Test-Path "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\SubsequentSyncs\$($date)\$($time)"
if($2nddirExists -eq $False) {mkdir "C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\SubsequentSyncs\$($date)\$($time)"}

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($NASItem in $NASItems)
{ 
    $pathOld = $NASItem.FullPath
    $pathNew = ($pathOld -replace '\\hq-nas-01', 'E:').TrimStart("\")
    $filename = $NASItem.FileName

    Start-Job -Name "Attic Copy $pathOld" -ScriptBlock {
        <#$archivedItems = (Invoke-GenericMethod `
        -Instance           ([Alphaleonis.Win32.Filesystem.Directory]) `
        -MethodName         EnumerateFileSystemEntryInfos `
        -TypeParameters     Alphaleonis.Win32.Filesystem.FileSystemEntryInfo `
        -MethodParameters   $arg[1], '*',
                            ([Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]'Files, Recursive, ContinueOnException'),
                            ([Alphaleonis.Win32.Filesystem.PathFormat]::FullPath)) | where-object {($_.LastModified) -eq "Tuesday, January 1, 1980 7:00:00 PM"}

        $AIOriginalPath = $($archivedItems.FullPath) -replace 'E:', '\\hq-nas-01'
        $excludedFiles = "`"$(($archivedItems.Fullpath) -join '" "')`""#>

       robocopy $args[0] $args[1] /E /B /COPYALL /DCOPY:T /R:0 /W:0 /FP /MT:100 /LOG+:"C:\Users\sd_Ashuttleworth\Desktop\Test\Final\Data\SubsequentSyncs\$($args[2])\$($args[3])\ATTIC_Sync_$($args[4]).log"
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
      } -ArgumentList $pathOld, $pathNew, $date, $time, $filename
}