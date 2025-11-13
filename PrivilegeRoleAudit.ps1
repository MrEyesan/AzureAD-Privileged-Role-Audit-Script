@'
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement, Microsoft.Graph.Users, Microsoft.Graph.Identity.Governance

<#
.SYNOPSIS
    Audits privileged role assignments in Azure AD / Microsoft Entra ID
.DESCRIPTION
    Scans critical Azure AD roles for members, checks for stale accounts, guest users,
    PIM eligibility, and generates a detailed CSV report with security recommendations.
.NOTES
    Author: EYESAN ORITSEJEMINEYIN
    Version: 1.0
    Prerequisites: Install-Module Microsoft.Graph -Scope CurrentUser
#>

# Configuration
$OutputPath = "C:\SecurityAudits\AzureAD_PrivilegedRoles\AzureAD_PrivilegedRoleAudit_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$SummaryPath = "C:\SecurityAudits\AzureAD_PrivilegedRoles\AzureAD_PrivilegedRoleAudit_Summary_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$StaleAccountDays = 90

# Define privileged roles to audit
$PrivilegedRoles = @(
    "Global Administrator",
    "Privileged Role Administrator",
    "Security Administrator",
    "Compliance Administrator",
    "Exchange Administrator",
    "SharePoint Administrator",
    "User Administrator",
    "Helpdesk Administrator",
    "Billing Administrator",
    "Application Administrator",
    "Cloud Application Administrator",
    "Authentication Administrator",
    "Privileged Authentication Administrator",
    "Conditional Access Administrator",
    "Intune Administrator",
    "Teams Administrator",
    "Global Reader"
)

Write-Host "Starting Azure AD Privileged Role Audit..." -ForegroundColor Cyan
Write-Host "Audit Date: $(Get-Date)" -ForegroundColor Gray

# Connect to Microsoft Graph with required scopes
Write-Host "`nConnecting to Microsoft Graph..." -ForegroundColor Yellow
try {
    Connect-MgGraph -Scopes "Directory.Read.All", "RoleManagement.Read.All", "User.Read.All", "AuditLog.Read.All" -NoWelcome -ErrorAction Stop
    $TenantDetails = Get-MgOrganization
    Write-Host "Connected to tenant: $($TenantDetails.DisplayName)" -ForegroundColor Green
}
catch {
    Write-Host "Failed to connect to Microsoft Graph: $_" -ForegroundColor Red
    exit
}

$Results = @()
$TotalMembers = 0
$RedFlags = 0

# Get all directory roles
$AllRoles = Get-MgDirectoryRole -All

# Process each privileged role
foreach ($RoleName in $PrivilegedRoles) {
    Write-Host "`nChecking: $RoleName" -ForegroundColor Yellow
    
    try {
        # Find the role
        $Role = $AllRoles | Where-Object { $_.DisplayName -eq $RoleName }
        
        if (-not $Role) {
            Write-Host "  - Role not found or not activated in tenant" -ForegroundColor Gray
            continue
        }
        
        # Get role members
        $RoleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $Role.Id -All
        
        if ($RoleMembers) {
            foreach ($Member in $RoleMembers) {
                $TotalMembers++
                
                # Get detailed user information
                try {
                    $User = Get-MgUser -UserId $Member.Id -Property Id,DisplayName,UserPrincipalName,AccountEnabled,CreatedDateTime,SignInActivity,UserType,OnPremisesSyncEnabled,Mail -ErrorAction Stop
                    
                    # Get last sign-in date
                    $LastSignIn = $null
                    $DaysSinceSignIn = "Never"
                    
                    if ($User.SignInActivity) {
                        if ($User.SignInActivity.LastSignInDateTime) {
                            $LastSignIn = $User.SignInActivity.LastSignInDateTime
                            $DaysSinceSignIn = (New-TimeSpan -Start $LastSignIn -End (Get-Date)).Days
                        }
                        elseif ($User.SignInActivity.LastNonInteractiveSignInDateTime) {
                            $LastSignIn = $User.SignInActivity.LastNonInteractiveSignInDateTime
                            $DaysSinceSignIn = (New-TimeSpan -Start $LastSignIn -End (Get-Date)).Days
                        }
                    }
                    
                    # Determine account type
                    $AccountType = if ($User.UserType -eq "Guest") {
                        "Guest User"
                    }
                    elseif ($User.UserPrincipalName -like "*#EXT#*") {
                        "External User"
                    }
                    elseif ($User.OnPremisesSyncEnabled -eq $true) {
                        "Synced User"
                    }
                    elseif ($User.UserPrincipalName -like "svc_*" -or $User.UserPrincipalName -like "*service*") {
                        "Service Account"
                    }
                    else {
                        "Cloud User"
                    }
                    
                    # Check if account is licensed
                    $AssignedLicenses = (Get-MgUser -UserId $User.Id -Property AssignedLicenses).AssignedLicenses
                    $IsLicensed = $AssignedLicenses.Count -gt 0
                    
                    # Flag potential issues
                    $Issues = @()
                    
                    if (-not $User.AccountEnabled) {
                        $Issues += "DISABLED_ACCOUNT"
                        $RedFlags++
                    }
                    
                    if ($DaysSinceSignIn -ne "Never" -and $DaysSinceSignIn -gt $StaleAccountDays) {
                        $Issues += "STALE_ACCOUNT_${StaleAccountDays}+_DAYS"
                        $RedFlags++
                    }
                    
                    if ($DaysSinceSignIn -eq "Never") {
                        $Issues += "NEVER_SIGNED_IN"
                        $RedFlags++
                    }
                    
                    if ($User.UserType -eq "Guest") {
                        $Issues += "GUEST_USER_WITH_ADMIN_ROLE"
                        $RedFlags++
                    }
                    
                    if ($RoleName -eq "Global Administrator" -and $AccountType -notin @("Service Account", "Break-Glass")) {
                        $Issues += "REGULAR_USER_AS_GLOBAL_ADMIN"
                        $RedFlags++
                    }
                    
                    if (-not $IsLicensed -and $AccountType -ne "Service Account") {
                        $Issues += "UNLICENSED_ADMIN_ACCOUNT"
                    }
                    
                    if ($User.OnPremisesSyncEnabled -eq $true -and $RoleName -eq "Global Administrator") {
                        $Issues += "SYNCED_GLOBAL_ADMIN"
                        $RedFlags++
                    }
                    
                    $IssueString = if ($Issues) { $Issues -join "; " } else { "None" }
                    
                    # Check for PIM eligibility (if available)
                    $PIMEligible = "N/A"
                    try {
                        # This requires additional permissions and may not work in all tenants
                        $PIMAssignment = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -Filter "principalId eq '$($User.Id)' and roleDefinitionId eq '$($Role.Id)'" -ErrorAction SilentlyContinue
                        if ($PIMAssignment) {
                            $PIMEligible = "Yes (PIM Eligible)"
                        }
                    }
                    catch {
                        # PIM check failed, continue without it
                    }
                    
                    # Build result object
                    $Results += [PSCustomObject]@{
                        RoleName = $RoleName
                        UserPrincipalName = $User.UserPrincipalName
                        DisplayName = $User.DisplayName
                        AccountType = $AccountType
                        UserType = $User.UserType
                        Enabled = $User.AccountEnabled
                        Licensed = $IsLicensed
                        LastSignIn = if ($LastSignIn) { $LastSignIn.ToString("yyyy-MM-dd HH:mm:ss") } else { "Never" }
                        DaysSinceSignIn = $DaysSinceSignIn
                        AccountCreated = $User.CreatedDateTime.ToString("yyyy-MM-dd")
                        SyncedFromOnPrem = if ($User.OnPremisesSyncEnabled) { "Yes" } else { "No" }
                        PIMStatus = $PIMEligible
                        Email = $User.Mail
                        Issues = $IssueString
                    }
                    
                    Write-Host "  - $($User.UserPrincipalName) ($AccountType) - Issues: $IssueString" -ForegroundColor $(if ($Issues) { "Red" } else { "Green" })
                }
                catch {
                    Write-Host "  - Error getting details for member: $_" -ForegroundColor Red
                }
            }
        }
        else {
            Write-Host "  - No members found" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  - Error accessing role: $_" -ForegroundColor Red
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph | Out-Null

# Export to CSV
$Results | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Host "`nResults exported to: $OutputPath" -ForegroundColor Green

# Generate Summary Report
$Summary = @"
=====================================================
AZURE AD PRIVILEGED ROLE AUDIT SUMMARY
=====================================================
Audit Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Tenant: $($TenantDetails.DisplayName)
Tenant ID: $($TenantDetails.Id)

STATISTICS
-----------------------------------------------------
Total Privileged Accounts: $TotalMembers
Total Issues Found: $RedFlags
Roles Audited: $($PrivilegedRoles.Count)

BREAKDOWN BY ROLE
-----------------------------------------------------
$($Results | Group-Object RoleName | ForEach-Object {
    "$($_.Name): $($_.Count) members"
} | Out-String)

ACCOUNT TYPE BREAKDOWN
-----------------------------------------------------
$($Results | Group-Object AccountType | ForEach-Object {
    "$($_.Name): $($_.Count) accounts"
} | Out-String)

ISSUE BREAKDOWN
-----------------------------------------------------
$($Results | Where-Object { $_.Issues -ne "None" } | Group-Object Issues | Sort-Object Count -Descending | ForEach-Object {
    "$($_.Name): $($_.Count) occurrences"
} | Out-String)

CRITICAL FINDINGS
-----------------------------------------------------
$(if ($Results | Where-Object { $_.Enabled -eq $false }) {
    "Disabled accounts still in privileged roles: $(($Results | Where-Object { $_.Enabled -eq $false }).Count)"
})
$(if ($Results | Where-Object { $_.DaysSinceSignIn -ne "Never" -and [int]$_.DaysSinceSignIn -gt $StaleAccountDays }) {
    "Stale accounts (no sign-in in $StaleAccountDays+ days): $(($Results | Where-Object { $_.DaysSinceSignIn -ne "Never" -and [int]$_.DaysSinceSignIn -gt $StaleAccountDays }).Count)"
})
$(if ($Results | Where-Object { $_.LastSignIn -eq "Never" }) {
    "Accounts never signed in: $(($Results | Where-Object { $_.LastSignIn -eq "Never" }).Count)"
})
$(if ($Results | Where-Object { $_.UserType -eq "Guest" }) {
    "Guest users with admin roles: $(($Results | Where-Object { $_.UserType -eq "Guest" }).Count)"
})
$(if ($Results | Where-Object { $_.Issues -like "*REGULAR_USER_AS_GLOBAL_ADMIN*" }) {
    "Regular users as Global Admins: $(($Results | Where-Object { $_.Issues -like "*REGULAR_USER_AS_GLOBAL_ADMIN*" }).Count)"
})
$(if ($Results | Where-Object { $_.Issues -like "*SYNCED_GLOBAL_ADMIN*" }) {
    "Synced accounts as Global Admins: $(($Results | Where-Object { $_.Issues -like "*SYNCED_GLOBAL_ADMIN*" }).Count)"
})
$(if ($Results | Where-Object { $_.Licensed -eq $false -and $_.AccountType -ne "Service Account" }) {
    "Unlicensed admin accounts: $(($Results | Where-Object { $_.Licensed -eq $false -and $_.AccountType -ne "Service Account" }).Count)"
})

GLOBAL ADMINISTRATORS
-----------------------------------------------------
$($Results | Where-Object { $_.RoleName -eq "Global Administrator" } | ForEach-Object {
    "$($_.UserPrincipalName) - $($_.AccountType) - Last Sign-In: $($_.LastSignIn)"
} | Out-String)

RECOMMENDATIONS
-----------------------------------------------------
1. Remove disabled accounts from all privileged roles immediately
2. Review stale accounts - consider disabling or removing privileges
3. Guest users should NEVER have privileged roles - remove immediately
4. Use separate admin accounts for privileged access (not daily-use accounts)
5. Implement Privileged Identity Management (PIM) for just-in-time access
6. Synced Global Admins create hybrid attack paths - use cloud-only accounts
7. Limit Global Administrators to 2-5 break-glass accounts maximum
8. Enable MFA for ALL privileged accounts (no exceptions)
9. Use Conditional Access to restrict admin sign-ins by location/device
10. Conduct monthly reviews of privileged role assignments

ZERO TRUST PRINCIPLES
-----------------------------------------------------
- Verify explicitly: Require MFA for all admin accounts
- Use least privileged access: Assign minimum role needed
- Assume breach: Monitor all privileged account activity
- Use PIM: Just-in-time access instead of standing privileges

=====================================================
"@

$Summary | Out-File -FilePath $SummaryPath
Write-Host "`nSummary report saved to: $SummaryPath" -ForegroundColor Green

# Display summary to console
Write-Host "`n$Summary" -ForegroundColor Cyan

Write-Host "`nAudit Complete!" -ForegroundColor Green
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Review the CSV for detailed findings" -ForegroundColor White
Write-Host "2. Address critical issues (disabled accounts, guests with admin)" -ForegroundColor White
Write-Host "3. Implement PIM for just-in-time privileged access" -ForegroundColor White
Write-Host "4. Schedule this audit to run monthly" -ForegroundColor White
'@ | Out-File -FilePath "C:\SecurityAudits\AzureAD_PrivilegedRoles\AzureAD-PrivilegedRoleAudit.ps1" -Encoding UTF8
