$DeptErrors = Import-Csv C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Departments\Endeavor_Copy2_Error_Departments.log
$FCSErrors = Import-Csv C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\fcs\Endeavor_Copy2_Error_fcs.log
$MediaErrors = Import-Csv C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Media\Endeavor_Copy2_Error_Media.log
$ProjectsErrors = Import-Csv C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Projects\Endeavor_Copy2_Error_Projects.log

$dept = ($DeptErrors | where {$_ -like "*\\hq-*"})
$fcs = ($FCSErrors | where {$_ -like "*\\hq-*"})
$Media = ($MediaErrors | where {$_ -like "*\\hq-*"})
$Projects = ($ProjectsErrors | where {$_ -like "*\\hq-*"})

$dept | Out-file C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List.csv -Append
$fcs | Out-file C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List.csv -Append
$Media | Out-file C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List.csv -Append
$Projects | Out-file C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List.csv -Append

$csv = C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List.csv
$csv.Size

$DeptCount = $dept.count
$FCSCount = $fcs.count
$MediaCount = $Media.count
$ProjectsCount = $Projects.count

$TotalCount = $DeptCount + $FCSCount + $MediaCount + $ProjectsCount

