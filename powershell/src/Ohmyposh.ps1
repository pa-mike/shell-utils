
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

InstallModule-Check "oh-my-posh"
Add-LineToProfile "Import-Module oh-my-posh"

if ($IsMacOS -or $IsLinux) {
    $path_char = "/"
}
elseif ($IsWindows -or $env:OS) {
    $path_char = "\"
}

Add-LineToProfile "(@(oh-my-posh init pwsh --config=`"$((Split-Path (Split-Path (Split-Path $PSCommandPath -Parent) -Parent ) -Parent ))$($path_char)ohmyposh$($path_char)ohmyposh-config.json`" --print) -join `"``n`") `| Invoke-Expression"
