Install-Module -Name Pester -Force -SkipPublisherCheck

Invoke-Pester ".\utils.Tests.ps1" -CodeCoverage "..\src\utils.ps1"