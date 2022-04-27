
Set-Location (Split-Path -Path $PSCommandPath)
Import-Module .\utils.ps1
if ($IsMacOS -or $IsLinux) {
    Invoke-Expression "sudo -v"
}
elseif ($IsWindows -or $env:OS) {
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Timestamp-Echo "Running in Administrator window..."
        Start-Process PowerShell.exe " -NoProfile -NoExit -ExecutionPolicy Bypass -File $($PSCommandPath)" -Verb RunAs
        exit
    }
    else {
        Timestamp-Echo "Running as Administrator"
    }
}


InstallModule-Check "PSReadLine" "2.1.0"
Add-LineToProfile "Import-Module PSReadLine"
Add-LineToProfile "Set-PSReadLineOption -PredictionSource History"