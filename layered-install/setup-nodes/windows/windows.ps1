param (
    [switch]$winget = $false,
    [switch]$tools = $false,
    [switch]$qol = $false,
    [switch]$business = $false,
    [switch]$help = $false
)
$scriptName = split-path $PSCommandPath -Leaf

if ($help) {
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Base windows install script, can install base tools, qol, and business tools. 
    -winget: installs winget
    -tools: installs default tools (requires winget)
    -qol: installs qol tools (requires winget)
    -business: installs business tools (requires winget)
    -help: help"
    exit
}

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Running in Administrator window..."
    Start-Process PowerShell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

if ($winget) {
    # Get winget and its dependencies without signing into MS Store
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'

    # Check if VCLibs exists, and if its missing, download and install
    $packageInfo = Get-AppxPackage -Name "Microsoft.VCLibs.140.00"
    if ( $packageInfo.length -gt 0) {
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Microsoft.VCLibs.140.00 already exists, skipping"
        
    }
    else 
    {
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Downloading Microsoft.VCLibs.140.00"
        $filepath = $env:userprofile + "\AppData\Local\Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $ProgressPreference = 'SilentlyContinue' # Hide WebRequest Update so it goes
        Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $filepath
        $ProgressPreference = 'Continue' # Make WebRequest Update 
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing Microsoft.VCLibs.140.00"
        add-appxpackage -Path $filepath
    }

    # Check if Winget exists, and if its missing, download and install
    $packageInfo = Get-AppxPackage -Name "Microsoft.Winget.Source"
    if ( $packageInfo.length -gt 0) {
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Winget already exists, skipping"
    }
    else 
    {
        
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Downloading Winget"
        $filepath = $env:userprofile + "\AppData\Local\Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $ProgressPreference = 'SilentlyContinue' # Hide WebRequest Update so it goes
        Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/download/v1.1.12653/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile $filepath
        $ProgressPreference = 'Continue' # Make WebRequest Update 
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing Winget"
        add-appxpackage -Path $filepath
    }
}

if ($tools) {
   $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing base tools"
    winget install Google.Chrome --source winget --force
    winget install SlackTechnologies.Slack --source winget
    winget install Notion.Notion --source winget
    winget install Google.BackupAndSync --source winget
    winget install Miro.Miro --source winget
}

if ($qol) {
   $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing quality of life tools"
    winget install VideoLAN.VLC --source winget
    winget install voidtools.Everything --source winget
    winget install Microsoft.PowerToys --source winget
    winget install 7zip. --source winget
    winget install Notepad++.Notepad++ --source winget
    winget install WinDirStat.WinDirStat --source winget
    winget install Sejda.PDFDesktop --source winget
}

if ($business) {
   $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing business tools"
    winget install Microsoft.OneDrive --source winget
    winget install Microsoft.officedeploymenttool --source winget
    winget install Zoom.Zoom --source winget
}