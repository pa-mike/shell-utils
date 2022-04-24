param (
    [string]$distro = "Ubuntu-20.04",
    [string]$installUser = $env:UserName,
    [switch]$list = $false,
    [switch]$wsl = $false,
    [switch]$tools = $false,
    [switch]$qol = $false,
    [switch]$extensions = $false,
    [switch]$launch = $false,
    [switch]$help = $false

)
$scriptName = split-path $PSCommandPath -Leaf

if ($help) {
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Dev setup
    -distro: specify a wsl distro to install inside. Default distro to install inside: Ubuntu-20.04
    -list: list out available distros in this script
    -wsl: run setup script for wsl distro
    -tools: install tools
    -qol: install qol patches and tools
    -extensions: install vscode extensions
    -launch: once done launch vscode into new wsl2 instance
    -help: help"
    exit
}


if ($list) {
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Available Distros:
    Ubuntu-20.04
    Ubuntu-18.04
    Ubuntu-16.04
    Debian
    kali-linux
    SLES-12
    openSUSE-42"
    exit
}


if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Running in Administrator window..."
    Start-Process PowerShell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}


if ([System.Environment]::OSVersion.Version.Build -lt 18362)
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Requires Win10+, Build 18362 or later. Please update your windows"
    exit 2
}


# Set our Distro Variables. Replace these with appropriate links / info from your preffered distro here:
# https://docs.microsoft.com/en-us/windows/wsl/install-manual#downloading-distributions
if ($distro -eq "Ubuntu-20.04"){
    $distroExecutableName = "ubuntu2004"
    $distroUrl = "https://aka.ms/wslubuntu2004"
}
elseif ($distro -eq "Ubuntu-18.04") {
    $distroExecutableName = "ubuntu1804"
    $distroUrl = "https://aka.ms/wsl-ubuntu-1804"
}
elseif ($distro -eq "Ubuntu-16.04") {
    $distroExecutableName = "ubuntu1604"
    $distroUrl = "https://aka.ms/wsl-ubuntu-1604"
}
elseif ($distro -eq "Debian") {
    $distroExecutableName = "debian"
    $distroUrl = "https://aka.ms/wsl-debian-gnulinux"
}
elseif ($distro -eq "kali-linux") {
    $distroExecutableName = "kali"
    $distroUrl = "https://aka.ms/wsl-kali-linux-new"
}
elseif ($distro -eq "SLES-12") {
    $distroExecutableName = "SLES-12"
    $distroUrl = "https://aka.ms/wsl-sles-12"
}
elseif ($distro -eq "openSUSE-42") {
    $distroExecutableName = "openSUSE-Leap-15.2"
    $distroUrl = "https://aka.ms/wsl-opensuseleap15-2"
}
else{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Unrecognized distro name: $distro, please enter recognized distro"
    exit
}


##############Installing base dev tools###################

function wsl
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting wsl bash setup in $distro"
    wsl -d $distro -u root -e bash ..../setup-nodes/devbase/dev.sh
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Successfully completed wsl dev setup"
}

function tools
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing tools"
    winget install dbeaver.dbeaver --source winget
    winget install Microsoft.AzureCLI --source winget
    winget install Microsoft.AzureStorageExplorer --source winget
    winget install Postman.Postman --source winget
    
}


function qol
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing qol"
    Copy-Item "..\setup-nodes\devbase\tools\ssh_config" -Destination "~\.ssh\config"
}


##############Installing base extensions###################

function extensions
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing extension pack to local vscode"
    code --install-extension ..\setup-nodes\devbase\vscode\deveteam\pa-devteam-vs-extensions-0.0.1.
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing extension pack to wsl remote vscode in $distro"
    wsl -d $distro code --install-extension ../setup-nodes/devbase/vscode/deveteam/pa-devteam-vs-extensions-0.0.1.vsix
}

##############Launch VS Code in $distro###################


if ($launch) {
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Launching vscode into remote wsl $distro"
    code --remote wsl+$distro
}

