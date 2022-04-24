
function Timestamp-Echo([string]$text, [string]$headerColor = "Green", [bool]$callStack = $true) {
    $PScallStack = $(Get-PSCallStack) # Get the call stack
    if ($callStack -eq $true -and $PScallStack.Count -ne 0 -and $PScallStack.Length -gt 1 -and "<No file>" -ne $PScallStack.ScriptName[0]) {
        # Call stack not null
        [array]::Reverse($PScallStack)
        $scripts = $PScallStack[0..($PScallStack.Length - 2)].ScriptName # Get all but the last item in our call stack, ie, this utils script function invocation
        $commandPath = (split-path $scripts -Leaf ) -join " > "
        $functionPath = ($(Get-PSCallStack)[1].FunctionName) -join " ~ "
        if ($functionPath -eq "<ScriptBlock>") { $functionString = " - " }else { $functionString = " ~ $functionPath - " }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        Write-Host "[$timestamp] $commandPath$functionString" -ForegroundColor $headerColor -NoNewline; 
        Write-Host "$text"

    }
    else {
        # Call stack null, print no call stack
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff";
        Write-Host "[$timestamp] " -ForegroundColor $headerColor -NoNewline; 
        Write-Host "$text"
    }
}

function Add-LineToProfile([string]$line) {
    $line_pattern = "^$($line -replace '[[+*?()\\.]','\$&')$" # escape strings
    # $line_pattern = "^$line_pattern$"
    IF ($null -ne $(Select-String -Path $profile -Pattern $line_pattern) ) {
        Timestamp-Echo "Powershell Profile $line already set, skipping" 
    }
    else {
        Timestamp-Echo "Setting Powershell Profile $line" 
        Add-Content -Path $profile -Value "
$line"
    }
}

function InstallModule-Check([string]$module_name, [string]$module_version = $null) {
    if (Get-Module -ListAvailable -Name $module_name) {
        $result = Timestamp-Echo "$module_name already installed"
        return "Already Installed"
    } 
    else {
        if ($null -eq $module_version -or "" -eq $module_version) {
            Timestamp-Echo "Installing $module_name"
            $result = (Install-Module $module_name -Force)
            return $result 
        }
        else {
            Timestamp-Echo "Installing $module_name Version $module_version"
            $result = (Install-Module $module_name -RequiredVersion $module_version  -Force)
            return $result

        }
    }
}





# function InstallAppx-Check([string]$package_name, [string]$package_version, [string]$source_url) {
#     # Get winget and its dependencies without signing into MS Store
#     [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'

#     # Check if VCLibs exists, and if its missing, download and install
#     $packageInfo = Get-AppxPackage -Name "$package_name.$package_version"
#     if ( $packageInfo.length -gt 0) {
#         Timestamp-Echo "$package_name.$package_version already exists, skipping"
#     }
#     else {
#         Timestamp-Echo "Downloading $package_name.$package_version from $source_url"
#         $filepath = $env:userprofile + "\AppData\Local\Temp\$package_name.$package_version.appx"
#         $ProgressPreference = 'SilentlyContinue' # Hide WebRequest Update so it goes
#         Invoke-WebRequest -Uri $source_url -OutFile $filepath
#         $ProgressPreference = 'Continue' # Make WebRequest Update 
#         Timestamp-Echo "Installing $package_name.$package_version"
#         add-appxpackage -Path $filepath
#     }
# }

