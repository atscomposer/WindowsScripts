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
$path           = "C:\Users\sd_Ashuttleworth\Desktop\Test\"
$log            = $path + "Atticprogress.log"

#----------------------------------------------------------
# LOAD FUNCTIONS
#----------------------------------------------------------

cd C:\Users\Public\AlphaFS.2.0.1\lib\net451

Import-Module -Name ".\AlphaFS.dll"

#----------------------------------------------------------
# SIZE CALCULATION
#----------------------------------------------------------

$dirEnumOptions = [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::Recursive -bor
                           [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::SkipReparsePoints -bor
                           [Alphaleonis.Win32.Filesystem.DirectoryEnumerationOptions]::ContinueOnException

$pathFormat = [Alphaleonis.Win32.Filesystem.PathFormat]::FullPath

 # Get aggregated properties, including size, of a folder.
$properties = [Alphaleonis.Win32.Filesystem.Directory]::GetProperties('E:\', $dirEnumOptions, $pathFormat)

$startSize = [math]::round($properties.Size.ToString() /1Gb, 0)

"$(Get-date): $($startSize) GB" | Out-File $log -Append 