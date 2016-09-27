@ECHO OFF

SET currentDir=%~dp0
SET PSScriptPath=%currentDir%rehydrateAttic_v2.ps1
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -file %PSScriptPath%' -Verb RunAs}"

exit