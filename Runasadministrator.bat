SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%Scan_currentUserinAD.ps1
powershell.exe -noprofile -executionpolicy Bypass -file "%PowerShellScriptPath%" -Verb RunAs
pause