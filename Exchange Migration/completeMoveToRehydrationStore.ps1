$suspended = Get-MoveRequest -MoveStatus AutoSuspended | select -ExpandProperty Identity
#$suspended = Get-MoveRequest -BatchName Group1 | select -ExpandProperty Identity

foreach ($s in $suspended) {
    Resume-MoveRequest -identity $s
}