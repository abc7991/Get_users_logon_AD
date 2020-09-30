
----------------------------------------INSTRUCTION---------------------------------------------------------------
1. Edit file Scan_currentUserinAD.ps1 by right-clicking on it and select Edit.
2. Update your username/password domain admin that already have administrator permission on client windows 10. If you have a trouble with account permission, please make sure your account is in administrator group in client - https://www.rebeladmin.com/2015/08/restricted-groups-using-group-policies/ 
3. Run as Administrator file RunasAdministrator.bat to run.

*Note:  
  + "Powershell is not recognized as an internal or external command operable ..". Please add %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\ to the Path enviroment.
  + The result is in C:\Scanresult\useronl.txt
