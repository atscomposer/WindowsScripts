$csv = Get-Content 'C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List_v2.csv'

foreach ($i in $csv){
    $cut1 = $i.Substring(31) 
    $cut1.Trim() | Out-File C:\Users\sd_ashuttleworth\Desktop\Endeavor\Restore\Final_Combined_Error_List_v3.csv -Append
    
}
