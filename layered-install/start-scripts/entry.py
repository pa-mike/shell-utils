
# Working on converting powershell scripts to py files to make them platform agnostic and flexible

import argparse

parser = argparse.ArgumentParser(description="Entry Script")
parser.add_argument('-BASE_SCRIPT', default= "../setup-nodes/windows/windows.ps1")

BASE_SCRIPT = "../setup-nodes/windows/windows.ps1"
DEVBASE_SCRIPT = "../setup-nodes/windows/devbase.ps1"
DEV_SCRIPT = "../setup-nodes/windows/dev.ps1"
DATA_SCRIPT ="../setup-nodes/windows/data.ps1"
installOption = -1
nolog = False
LOG_FILE = "default"




'''
param (
    [string]$BASE_SCRIPT = "../setup-nodes/windows/windows.ps1",
    [string]$DEVBASE_SCRIPT = "../setup-nodes/windows/devbase.ps1",
    [string]$DEV_SCRIPT = "../setup-nodes/windows/dev.ps1",
    [string]$DATA_SCRIPT ="../setup-nodes/windows/data.ps1",
    [int]$installOption = -1,
    [switch]$nolog = $false,
    [string]$LOG_FILE = "default"
)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
        Write-Host "Running in Administrator window..."
    Start-Process PowerShell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
Set-Location (Split-Path -Path $PSCommandPath)
write-host (Get-Location)

if($LOG_FILE -eq "default"){
    $timestamp = Get-Date -Format "yyy-mm-dd--HH-mm-ss"; $LOG_FILE = "$env:userprofile\AppData\Local\Temp\setup_script_install_run_$timestamp.txt"
}

$scriptName = split-path $PSCommandPath -Leaf

function Main-Menu 
{

        Write-Host "Provision Analytics Machine Setup"  -ForegroundColor Green; Write-Host "Please select one install option"
        do
        {
            Write-Host "1. Business `n2. Data `n3. Minimal Data Setup (No Extra Tools or QoL) `n4. Development `n5. Test Setup"
            $installOption = read-host [Enter Selection]
            Switch ($installOption) {
                "1" {business_setup}
                "2" {data_setup}
                "3" {minimal_data_setup}
                "4" {development_setup}
                "5" {test_setup}
            }
        }
        until (1..5 -contains $installOption) 

}

function reset_password_popup{
$a = new-object -comobject wscript.shell
$a.popup("Please reset your wsl2 user password in the next prompt",0,"Install Complete",0)
}

function business_setup 
{
    Start-Transcript -Path $LOG_FILE
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Starting Business Setup"
    PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget -tools -qol -business
    Stop-Transcript
}
function data_setup 
{
    Start-Transcript -Path $LOG_FILE
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Starting Data Setup"
    PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget -tools -qol
    PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -tools -qol -extensions
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -tools -installPy -qol -extensions
    reset_password_popup
    wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -launch
    Stop-Transcript
}
function minimal_data_setup 
{
    Start-Transcript -Path $LOG_FILE
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Starting Minimal Data Setup"
    PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget 
    PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -tools -qol
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -qol -extensions
    reset_password_popup
    wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -launch
    Stop-Transcript
}

function development_setup 
{
    Start-Transcript -Path $LOG_FILE
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Starting Development Setup"
    PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget -tools -qol
    PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -tools -qol -extensions
    PowerShell.exe -ExecutionPolicy Bypass -File $DEV_SCRIPT -wsl -tools -qol -extensions
    reset_password_popup
    wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
    PowerShell.exe -ExecutionPolicy Bypass -File $DEV_SCRIPT -launch
    Stop-Transcript
}


function test_setup 
{
    Start-Transcript -Path $LOG_FILE
    $timestamp = Get-Date -Format g; Write-Host "[$timestamp] $scriptName - " -ForegroundColor Green -NoNewline; 
    Write-Host "Starting Test Setup"
    PowerShell.exe -ExecutionPolicy Bypass -File $BASE_SCRIPT -winget 
    PowerShell.exe -ExecutionPolicy Bypass -File $DEVBASE_SCRIPT -wsl -qol
    PowerShell.exe -ExecutionPolicy Bypass -File $DATA_SCRIPT -wsl -qol -extensions
    reset_password_popup
    wsl -e passwd # MAKE SURE USER CHANGES WSL PASSWORD
    PowerShell.exe -ExecutionPolicy Bypass -File $DEV_SCRIPT -launch
    Stop-Transcript
}


Main-Menu
'''