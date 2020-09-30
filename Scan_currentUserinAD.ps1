#donwload RSAT from Microsoft
function installRSAT {
    $parameter = @{
        Uri = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS_1803-x64.msu'
        OutFile = "C:\WindowsTH-RSAT_WS_1803-x64.msu"
    }
    Invoke-WebRequest @parameter
    Test-Path -Path "C:\WindowsTH-RSAT_WS_1803-x64.msu"
    #install RSAT
    wusa.exe /quite /noreboot C:\WindowsTH-RSAT_WS_1803-x64.msu
}
#check msc
$dsaPath = "C:\WINDOWS\system32\dsa.ms"
$checkdsaPath = Test-Path -Path $dsaPath;
if ("$checkdsaPath" -eq "False"){
    installRSAT;
}
#define current folder
$Currentfolder = Split-Path $script:MyInvocation.MyCommand.Path;
$password = "Password@123" | ConvertTo-SecureString -asPlainText -Force;    #update password domain admin
$username = "a.nguyenvan@abc.com"                                           #update username domain admin
$ou = (Get-ADOrganizationalUnit -Identity $(($adComputer = Get-ADComputer -Identity $env:COMPUTERNAME).DistinguishedName.SubString($adComputer.DistinguishedName.IndexOf("OU=")))).DistinguishedName;
$cred = New-object System.Management.Automation.PSCredential($username,$password)
$hostcomputer = $env:COMPUTERNAME;
#get pc onl in AD
$computerad = get-adcomputer -Searchbase $ou -filter * -Properties operatingsystem | ? operatingsystem -match "windows" | Sort-Object name;
$filepath = "$Currentfolder\source\pconl.txt";
$filepath1 = "$Currentfolder\source\pcoffl.txt";
Out-File -FilePath $filepath;
Out-File -FilePath $filepath1;
Write-Host "Loading...Please wait" -ForegroundColor Yellow;
foreach ($cp in $computerad){
    $cps = $cp.dnshostname;
    if (Test-Connection -ComputerName $cps -Quiet -Count 1){
        Add-Content -Path $filepath -Value $cp.Name -Force;
    }else {
        Add-Content -Path $filepath1 -Value $cp.Name -Force;
    }
}
$computeradonl = Get-Content -Path $filepath;
$computeradonlnumber = $computeradonl.count;
Write-Host "Total computer onine is $computeradonlnumber" -ForegroundColor Green;
#get current logged on user into useronl list
New-Item -Path "C:\" -Name "Scanresult" -ItemType "directory" -Force;
$filepath2 = "C:\Scanresult\useronl.txt";
Out-File -FilePath $filepath2;
Add-Content -Path $filepath2 -Value "Computer;Username1;Username2";
new-smbshare -Name "localdisk" -Path "C:\Scanresult" -FullAccess "everyone" -ErrorAction SilentlyContinue;

foreach ($cpn in $computeradonl){
    Invoke-Command -ComputerName $cpn -Credential $cred -ScriptBlock{
        param([string]$hostcomputer, $cred)
        $getusername = (Get-ComputerInfo).CsUserName;
            if ($null -eq $getusername){
                $getlocalmember = Get-LocalGroupMember Administrators | Where-Object {$_.ObjectClass -eq "User"} | Where-Object {$_.PrincipalSource -eq "ActiveDirectory"};
                $username = $getlocalmember.Name;
            }
        $getcpname = $env:computername;
        New-PSDrive -Name "K" -PSProvider FileSystem -Root \\$hostcomputer\localdisk -Persist -Credential $cred;
        Add-Content -Path "K:\useronl.txt" -Value "$getcpname;$getusername;$username" -Force;
        Remove-PSdrive K;
    } -ArgumentList $hostcomputer,$cred;
}
Write-Host "Check a result in C:\Scanresult\useronl.txt" -ForegroundColor Green;
Invoke-Item "C:\Scanresult"
