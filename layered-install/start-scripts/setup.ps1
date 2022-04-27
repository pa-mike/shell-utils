param (
    [string]$BASE_SCRIPT = "../setup-nodes/windows/windows.ps1",
    [string]$DEVBASE_SCRIPT = "../setup-nodes/windows/devbase.ps1",
    [string]$DEV_SCRIPT = "../setup-nodes/windows/dev.ps1",
    [string]$DATA_SCRIPT ="../setup-nodes/windows/data.ps1",
    [string]$RESTART_SCRIPT = "../setup-nodes/windows/restart.ps1",
    [int]$installOption = -1,
    [string]$installUser = "wsluser",
    [switch]$nolog = $false,
    [string]$LOG_FILE = "default",
    [switch]$manualRun = $false,
    [string]$script = "",
    [parameter(mandatory=$false, position=2, ValueFromRemainingArguments=$true)]$param
)

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

script_elevate
set_pwd_to_script_location



if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Running in Administrator window..."
    Start-Process PowerShell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}




if($LOG_FILE -eq "default"){
    $timestamp = Get-Date -Format "yyy-mm-dd--HH-mm-ss"; $LOG_FILE = "$env:userprofile\AppData\Local\Temp\setup_script_install_run_$timestamp.txt"
}

$scriptName = split-path $PSCommandPath -Leaf

function Main-Menu 
{
        Write-Host "Provision Analytics Machine Setup"  -ForegroundColor Green; Write-Host "Please select one install option"
        do
        {
            Write-Host "1. Windows Features`n2. Business `n3. Full Data Setup (Requires Running #1 First)`n4. Minimal Data Setup (Data Tools Only)  (Requires Running #1 First) `n5. Data WSL2 Setup Only  (Requires Running #1 First, and existing installation of VS Code, Docker Desktop)`n6. Development"
            $installOption = read-host [Enter Selection]
            Switch ($installOption) {
                "1" {test_setup}
                "2" {business_setup}
                "3" {data_setup}
                "4" {minimal_data_setup}
                "5" {datawsl}
                "6" {development_setup}
            }
        }
        until (1..5 -contains $installOption) 

}

function reset_password_popup{
$a = new-object -comobject wscript.shell
$a.popup("Please reset your wsl2 user password in the next prompt",0,"Install Complete",0)
}

function business_setup {

        Start-Transcript -Path $LOG_FILE
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting Business Setup"
        PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget -tools -qol -business
        Stop-Transcript

}
function data_setup {

        Start-Transcript -Path $LOG_FILE
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting Data Setup"
        PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget -tools -qol
        # PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -winFeature
        PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -installUser $installUser -tools -qol -installPy -installWslPy -extensions
        PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -installUser $installUser -tools -qol -extensions
        Write-Host "Please reset your wsl2 user password in the next prompt"
        reset_password_popup
        wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
        PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -launch
        Stop-Transcript

}
function minimal_data_setup{

        Start-Transcript -Path $LOG_FILE
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting Minimal Data Setup"
        PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget 
        # PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -winFeature
        PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -installUser $installUser -tools -qol -installPy -installWslPy
        PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -installUser $installUser -qol -extensions
        Write-Host "Please reset your wsl2 user password in the next prompt"
        reset_password_popup
        wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
        PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -launch
        Stop-Transcript

}

function datawsl{

    Start-Transcript -Path $LOG_FILE
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Starting Minimal Data Setup"
    PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget 
    # PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -winFeature
    PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -installUser $installUser -installPy -installWslPy
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -installUser $installUser -qol -extensions
    Write-Host "Please reset your wsl2 user password in the next prompt"
    reset_password_popup
    wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -launch
    Stop-Transcript

}

function development_setup{

        Start-Transcript -Path $LOG_FILE
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting Development Setup"
        PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget -tools -qol
        # PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -winFeature
        PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -installUser $installUser -tools -qol -installPy -installWslPy -extensions
        PowerShell.exe -ExecutionPolicy Bypass -File $DEV_SCRIPT -wsl -installUser $installUser -tools -qol -extensions
        Write-Host "Please reset your wsl2 user password in the next prompt"
        reset_password_popup
        wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
        PowerShell.exe -ExecutionPolicy Bypass -File $DEV_SCRIPT -launch
        Stop-Transcript

}

function test_setup{

        Start-Transcript -Path $LOG_FILE
        $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Starting Test Setup"
        # PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget 
        PowerShell.exe -ExecutionPolicy Bypass -File $RESTART_SCRIPT
        # PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -qol -installPy -installWslPy
        # PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -qol -extensions
        # Write-Host "Please reset your wsl2 user password in the next prompt"
        # reset_password_popup
        # wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
        # PowerShell.exe -ExecutionPolicy Bypass -File $DEV_SCRIPT -launch
        Stop-Transcript

}

if ($manualRun){
    Switch ($script) {
        "base" {$targetScript = $BASE_SCRIPT}
        "devbase" {$targetScript = $DEVBASE_SCRIPT}
        "dev" {$targetScript = $DEV_SCRIPT}
        "data" {$targetScript = $DATA_SCRIPT}
    }
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Running " -NoNewline;
    Write-Host "$targetScript" -ForegroundColor Green -NoNewline;
    Write-Host " manually with parameters: " -NoNewline;
    Write-Host "$param" -ForegroundColor Green
    $psArgs = "PowerShell.exe -ExecutionPolicy Bypass -File "+$targetScript + " " + $param
    PowerShell.exe -ExecutionPolicy Bypass -Command $psArgs
}
else{
    Main-Menu

}
