Import-Module ActiveDirectory

$users = (Get-ADGroupMember -identity 'Exchange Migration POC - Group 2') | select -ExpandProperty SamAccountName
#$users = 'irobotmdm'

foreach ($user in $users){
    New-MoveRequest -identity $user -TargetDatabase 'Office 365 - Rehydration' -BadItemLimit 15 -SuspendWhenReadyToComplete -BatchName Group2
}