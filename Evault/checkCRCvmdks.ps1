$tasks = 15,16,17,18,19,20,21,23,24,25,26,27,28,29,31,32,33,34,36,94,95,100

foreach ($task in $tasks){
    Start-Job -Name "Check Pool Files Exist - $task" -ScriptBlock {
        C:\Director\prog\VVPoolOp.exe checkcrc task $args[0]
    } -ArgumentList $task
}