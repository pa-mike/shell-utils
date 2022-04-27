param (
    [string]$distro = "Ubuntu-20.04",
    [string]$installUser = $env:UserName,
    [switch]$winFeature = $false,
    [switch]$wsl = $false,
    [switch]$setDefault = $true,
    [switch]$list = $false,
    [switch]$tools = $false,
    [switch]$installPy = $false,
    [switch]$installWslPy = $false,
    [string]$pyVersion = "3",
    [switch]$qol = $false,
    [switch]$noLaunch = $false,
    [switch]$noExtensions = $false,
    [switch]$help = $false 
    [switch]$renameDistro = $false,
    [string]$distroNewName = "",

)

# set default true argumrnets
# $noLaunch = $true
# $noExtensions = $true

# Set printout scriptname
$scriptName = split-path $PSCommandPath -Leaf

if( $PSBoundParameters.Values.Count -eq 0 -and $args.count -eq 0 ) {
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installs wsl2, configures base user in wsl2, installs development tools, and vscode extensions
    -wsl: install wsl2, distro
    -distro: specify distro to install. Default distro to install: Ubuntu-20.04
    -pass: default password for user account in wsl (remember to change this!)
    -list: list out available distros in this script
    -tools: install tools
    -installPy: install python locally, default version 3 (latest)
    -installWslPy: install python in wsl, default version 3 (latest)
    -pyVersion: comma separated list of versions to install (eg, '3, 3.9, 3.1.1150')
    -qol: install qol patches and tools
    -noExtensions: skip installing vscode extensions
    -noLaunch: skip launching vscode into new wsl2 instance
    -renameDistro: Configure registry to rename the distro to the value provided with -distroNewName
    -distroNewName: if -renameDistro is set, rename distro to this name
    -help: print out help/usage info"
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

if ($winFeature){
    if ([System.Environment]::OSVersion.Version.Build -lt 18362)
    {
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Requires Win10+, Build 18362 or later. Please update your windows"
        exit 2
    }
    
    ##############Downloading and installing $distro###################

    # Enable wsl, set default version
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Setting Windows Features VirtualMachinePlatform, Microsoft-Windows-Subsystem-Linux"
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform, Microsoft-Windows-Subsystem-Linux -NoRestart
    Restart-Computer -Wait

}

if ($wsl){

    if ([System.Environment]::OSVersion.Version.Build -lt 18362)
    {
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Requires Win10+, Build 18362 or later. Please update your windows"
        exit 2
    }
    # Prepare for renaming distro by saving an array of exising wsl distros, if they exist
    if ($renameDistro){
        try {
            $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
                Write-Host "Renaming $distro to $distroNewName"
            $exising_info = Get-ItemProperty HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss\
            $exising_wsl_keys =  Get-ChildItem HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss\
            $defaultDistro = $exising_wsl_keys.DefaultDistribution
        }
        catch {
            $exising_info = @{}
            $exising_wsl_keys = @{}
        }
    }

    ##############Downloading and installing $distro###################


    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Setting default wsl to wsl2"
    wsl --set-default-version 2

    # Clear existing wsl distro if exists
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Clearing existing wsl distro $distro if it exists"
    wsl --unregister $distro

    # Set Tls12 protocol to be able to download the wsl application
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Check to see if distro installation file exists and download the app otherwise
    $filepath = $env:userprofile+ "\AppData\Local\Temp\$distro.appx"

    if (Test-Path $filepath -PathType leaf) 
    {$timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "File $filepath already exists, using that"}
    else
    {
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Downloading $distro"
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $distroUrl -OutFile $filepath -UseBasicParsing
        $ProgressPreference = 'Continue'
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Downloaded $distro"
    }


    # Install distro from package
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Attempting to install $distro"
    invoke-expression -Command "Add-AppxPackage $filepath"


    ##############Initializing wsl distro without requiring user input###################

    # First define path to the installed distroExecutable
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Setting up root in $distro"
    $str1="/Users/"
    $str2="/AppData/Local/Microsoft/WindowsApps/$distroExecutableName"
    $hdd_name=(Get-WmiObject Win32_OperatingSystem).SystemDrive
    $username=$env:UserName
    [String] $distro_path=$hdd_name+$str1+$username+$str2

    # install as root with no prompts
    $str1=" install --root"
    $set_user=$distro_path+$str1
    invoke-expression -Command $set_user

    # Add current user to distro sudo users, configure bash, set as default user
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Adding user $installUser with detault password $pass (please change once finished!)"
    wsl -d $distro -u root -e sudo useradd -m  $installUser -p imXmZYYtE2U3A # THIS IS INSECURE, MAKE SURE STAFF CHANGE PASSWORD ONCE SETUP IS COMPLETE
    wsl -d $distro -u root -e sudo usermod -aG sudo $installUser 
    wsl -d $distro -u root -e sudo chsh -s /bin/bash $installUser
    $distro_default_user=$distro_path+" config --default-user $installUser"
    invoke-expression -Command $distro_default_user

    if($setDefault){
    # Set Default wsl distro
    wsl --set-default $distro
    }
    
    # Rename our new distro
    if ($renameDistro){
        try {
            $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
                Write-Host "Renaming $distro to $distroNewName"
            $exising_info = Get-ItemProperty HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss\
            $exising_wsl_keys =  Get-ChildItem HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss\
            $defaultDistro = $exising_wsl_keys.DefaultDistribution
        }
        catch {
            $exising_info = @{}
            $exising_wsl_keys = @{}
        }
    }

    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Successfully completed install of $distro, default username: $installUser"

    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting wsl bash setup in $distro"
    wsl -d $distro -u root -e bash ../setup-nodes/devbase/devBase.sh
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Successfully completed base wsl dev setup"

}

##############Installing base dev tools###################

if ($tools) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing tools"
    winget install Microsoft.VisualStudioCode --source winget
    winget install Docker.DockerDesktop --source winget
    winget install Git.Git --source winget
    winget install GitHub.GitHubDesktop --source winget
    winget install PuTTY.PuTTY --source winget
}

if ($installPy){
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing Python $pyVersion locally"
    if($pyVersion -eq "3"){
        winget install Python.Python.3 --source winget
    }
    else{
        winget install Python.Python.3 -v $pyVersion --source winget
    }
}
if ($installWslPy){
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing Python $pyVersion into wsl $distro"
    wsl -d $distro -u root -e sudo apt-get install python$pyVersion -y
}

if ($qol) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing qol"
    reg import "..\setup-nodes\windows\tools\Add_Open_Command_Window_Here_as_Administrator.reg"
    PowerShell.exe -ExecutionPolicy Bypass -File "..\setup-nodes\windows\tools\openhere.ps1"
}

##############Installing base extensions###################

if (-Not $noExtensions) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing extension pack to local vscode"
    code --install-extension ..\setup-nodes\devbase\vscode\base\pa-base-development-extensions-0.0.1.vsix
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Installing extension pack to wsl remote vscode in $distro"
    wsl -d $distro code --install-extension ../setup-nodes/devbase/vscode/base/pa-base-development-extensions-0.0.1.vsix
}

##############Launch VS Code in $distro###################


if (-Not $noLaunch) {
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Launching vscode into remote wsl $distro"
    code --remote wsl+$distro
}