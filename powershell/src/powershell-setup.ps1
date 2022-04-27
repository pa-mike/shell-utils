
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

if ($IsMacOS -or $IsLinux) {
    $path_char = "/"
    Set-Alias -Name powershell -Value pwsh
}
elseif ($IsWindows -or $env:OS) {
    $path_char = "\"
   
}

powershell ./Ohmyposh.ps1
powershell ./PSReadline.ps1