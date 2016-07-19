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
$logInitial     = $path + "ATTIC_Copy_InitialCopy_160119.log"

#----------------------------------------------------------
# DIRECTORY VARIABLES (CHANGE AS NEEDED)
#----------------------------------------------------------

$dir1 = '\\hq-nas-01\files$\files\'
$dir2 = 'G:\files$\files\'

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------

robocopy $dir1 $dir2 /E /COPYALL /DCOPY:T /R:0 /W:0 /FP /NS /NC /NDL /MT:50 /LOG+:$logInitial