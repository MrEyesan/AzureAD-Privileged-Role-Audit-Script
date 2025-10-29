<#
.SYNOPSIS
    Automated prerequisite installation script
.DESCRIPTION
    Installs all required modules and configures environment
#>

Write-Host "Azure AD Privileged Role Audit - Prerequisite Installer" -ForegroundColor Cyan
Write-Host "========================================================`n" -ForegroundColor Cyan

# Check PowerShell version
Write-Host "Checking PowerShell version..." -ForegroundColor Yellow
$PSVersion = $PSVersionTable.PSVersion
Write-Host "Current version: $PSVersion" -ForegroundColor Green

if ($PSVersion.Major -lt 5) {
    Write-Host "ERROR: PowerShell 5.1 or later required!" -ForegroundColor Red
    exit 1
}

# Check execution policy
Write-Host "`nChecking execution policy..." -ForegroundColor Yellow
$Policy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "Current policy: $Policy" -ForegroundColor Green

if ($Policy -eq "Restricted") {
    Write-Host "Setting execution policy to RemoteSigned..." -ForegroundColor Yellow
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# Install Microsoft Graph
Write-Host "`nInstalling Microsoft Graph PowerShell SDK..." -ForegroundColor Yellow
if (Get-Module Microsoft.Graph -ListAvailable) {
    Write-Host "Microsoft Graph already installed" -ForegroundColor Green
    $Version = (Get-Module Microsoft.Graph -ListAvailable | Select-Object -First 1).Version
    Write-Host "Version: $Version" -ForegroundColor Green
} else {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
    Write-Host "Microsoft Graph installed successfully!" -ForegroundColor Green
}

# Create directory structure
Write-Host "`nCreating directory structure..." -ForegroundColor Yellow
$Paths = @(
    "C:\SecurityAudits",
    "C:\SecurityAudits\AzureAD_PrivilegedRoles",
    "C:\SecurityAudits\AzureAD_PrivilegedRoles\Reports",
    "C:\SecurityAudits\AzureAD_PrivilegedRoles\Logs"
)

foreach ($Path in $Paths) {
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "Created: $Path" -ForegroundColor Green
    }
}

Write-Host "`n✓ Prerequisites installed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Download the audit script to C:\SecurityAudits\AzureAD_PrivilegedRoles\" -ForegroundColor White
Write-Host "2. Run: .\AzureAD-PrivilegedRoleAudit.ps1" -ForegroundColor White
