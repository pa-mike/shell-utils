
function get_script_name{
    $scriptName = split-path $PSCommandPath -Leaf
    $functionName = $MyInvocation.MyCommand
    return $scriptName+$functionName
}

function timestamp-write([string]$text, [string]$headerColor = "Green"){
    $scriptName = $(get_script_name)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"; Write-Host "[$timestamp] $(get_script_name) - " -ForegroundColor $headerColor -NoNewline; 
    Write-Host "$text"
}




function elevate{
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
    {
        timestamp-write "Running in Administrator window..."
        Start-Process PowerShell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -Command cd $(Get-Location)" -Verb RunAs
        exit
    }
    else {
        timestamp-write "Already Running as Administrator"
    }
}

function script_elevate{
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
    {
        timestamp-write "Running in Administrator window..."
        Start-Process PowerShell.exe " -NoProfile -NoExit -ExecutionPolicy Bypass -File $($PSCommandPath)" -Verb RunAs
        exit
    }
    else {
        timestamp-write "Already Running as Administrator"
    }
}


function set_pwd_to_script_location{
    Set-Location (Split-Path -Path $PSCommandPath)
}

function get_winget {
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
        timestamp-write "Downloading Microsoft.VCLibs.140.00"
        $filepath = $env:userprofile + "\AppData\Local\Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $ProgressPreference = 'SilentlyContinue' # Hide WebRequest Update so it goes
        Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile $filepath
        $ProgressPreference = 'Continue' # Make WebRequest Update 
        timestamp-write "Installing Microsoft.VCLibs.140.00"
        add-appxpackage -Path $filepath
    }

    # Check if Winget exists, and if its missing, download and install
    $packageInfo = Get-AppxPackage -Name "Microsoft.Winget.Source"
    if ( $packageInfo.length -gt 0) {
        timestamp-write "Winget already exists, skipping"
    }
    else 
    {
        timestamp-write "Downloading Winget"
        $filepath = $env:userprofile + "\AppData\Local\Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $ProgressPreference = 'SilentlyContinue' # Hide WebRequest Update so it goes
        Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/download/v1.1.12653/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -OutFile $filepath
        $ProgressPreference = 'Continue' # Make WebRequest Update 
        timestamp-write "Installing Winget"
        add-appxpackage -Path $filepath
    }
}

function single_winget_install([string]$package_id, [string]$source = "winget"){
    # Check if winget exists
    $packageInfo = Get-AppxPackage -Name "Microsoft.Winget.Source"
    if ( $packageInfo.length -gt 0) {
        $upgradeCheck = winget upgrade $package_id --source $source --accept-package-agreements --accept-source-agreements
        if($upgradeCheck -eq "No applicable update found."){
            timpestamp-write "$package_id already installed, No applicable update found."
        }
        elseif($upgradeCheck -gt 4) {
            timpestamp-write "$package_id update found:`n$upgradeCheck"
        }
        else {
        winget install $package_id --source $source
        }
    }
    else {
        timestamp-write "Winget already exists, skipping"
    }
}

function loadYaml($pathTo){
    $yamlObj = (Get-Content "$pathTo" | Out-String | ConvertFrom-Yaml)
    return $yamlObj
}

function batch_winget_install([String[]]$package_ids){
    foreach($package_id in $package_ids){
        single_winget_install($package_id)
    }
}



function install_tool($tool){
        foreach($m in $tool.GetEnumerator()){
            $method = $($m.Name)
            if ($method -eq "powershell"){
                $($m.Value)
                # Start-Process PowerShell.exe " -NoProfile -NoExit -ExecutionPolicy Bypass -File $($PSCommandPath)"
            }
            foreach ($p in $($m.Value).GetEnumerator()){
                $parameter = $($p.Name)
                timestamp-write "$toolname $method $parameter"
            }
        }
    }


function batch_install_tool([System.Object[]]$tools){
    foreach($tool in $package_tools){

    }
}

Write-Host "hello!"-