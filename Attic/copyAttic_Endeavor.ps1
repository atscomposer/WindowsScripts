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
$dirs  =  get-content "\\hq-sccmfs-01\packages\scripts\Adam's Scripts\Endeavor\Endeavor_Robotics_Attic_Move.csv"

#----------------------------------------------------------
# INITIAL COPY FROM HQ-NAS-01
#----------------------------------------------------------
foreach ($dir in $dirs)
{
    $folder = Split-Path $dir -Leaf
    if ($dir -like "\\Attic*"){
        $pathNew = ($dir -replace 'attic', 'hq-san-01\endeavor')
        }
    if ($dir -like "\\hq-nas-01*"){
        $pathNew = ($dir -replace 'hq-nas-01', 'hq-san-01\endeavor')
        }
    Start-Job -Name "Attic Endeavor Copy $folder" -ScriptBlock {
       robocopy $args[0] $args[1] /S /B /E /XO /COPYALL /DCOPY:T /R:0 /W:0 /MT:100 /LOG+:"C:\Users\sd_ashuttleworth\Desktop\Endeavor\InitialSync\ATTIC_Endeavor_InitialCopy_$($args[2]).log"
       } -ArgumentList $dir, $pathNew, $folder
}
