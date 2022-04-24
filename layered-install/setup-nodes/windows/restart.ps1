if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    echo "Running in Administrator window..."
    Start-Process PowerShell.exe "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Install Powershell 7+ Preview
clear
echo "Installing Powershell 7+ Preview..."
Invoke-Expression "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Preview -Quiet -AddExplorerContextMenu -EnablePsRemoting"
echo ""


# Turn on Hyper-V Windows features
echo "Enabling the Windows Hypervisor virtualization features..."
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -Verbose -NoRestart -All
Enable-WindowsOptionalFeature -Online -FeatureName "HypervisorPlatform" -Verbose -NoRestart -All
echo ""

# Enable Virtual Machine feature
# Virtual Machine Platform - "Enables platform support for virtual machines" and is required for WSL2. Virtual Machine Platform can be used to create MSIX Application packages for an App-V or MSI.
echo "Enabling Virtual Machine Platform feature..."
Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -Verbose -NoRestart -All
echo ""


# Windows Sandbox - "Enables virtualization software to run on the Windows hypervisor" and at one time was required for Docker on Windows. The Hypervisor platform is an API that third-party developers can use in order to use Hyper-V. Oracle VirtualBox, Docker, and QEMU are examples of these projects.
# https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview#:~:text=To%20enable%20Sandbox%20using%20PowerShell,it%20for%20the%20first%20time.
echo "Enabling the Windows Sandbox..."
Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -Verbose -NoRestart -All
echo ""

# Enable the Windows Subsystem for Linux
echo "Enabling the Windows Subsystem for Linux..."
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -Verbose -NoRestart -All
echo ""

echo "Reboot required before running other scripts..."
Restart-Computer -Confirm
