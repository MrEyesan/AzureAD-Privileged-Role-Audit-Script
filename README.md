# Azure AD Privileged Role Security Audit Tool

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft_Azure-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Security](https://img.shields.io/badge/Security-Audit-red?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A comprehensive PowerShell-based security audit tool for identifying privileged account risks in Azure Active Directory (Microsoft Entra ID) environments.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Use Cases](#use-cases)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [What It Audits](#what-it-audits)
- [Output & Reports](#output--reports)
- [Sample Findings](#sample-findings)
- [Remediation Guide](#remediation-guide)
- [Security Best Practices](#security-best-practices)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

##  Overview

**Problem Statement:**  
Organizations often lack visibility into their Azure AD privileged role assignments, leading to security risks such as:
- Disabled accounts retaining administrative access
- Guest users with elevated permissions
- Stale accounts that haven't been used in months
- Regular user accounts with permanent admin rights
- Synced accounts as Global Administrators (hybrid attack path)

**Solution:**  
This automated audit tool scans all privileged roles in Azure AD, identifies security issues, and generates actionable reports with remediation recommendations.

**Business Impact:**
- ✅ Reduces attack surface by identifying unused privileged accounts
- ✅ Ensures compliance with security frameworks (CIS, NIST, Zero Trust)
- ✅ Saves money by identifying unnecessary license assignments
- ✅ Provides audit-ready documentation for compliance reviews

---

##  Features

### Security Auditing
- ✅ **Comprehensive Role Coverage** - Audits 17 critical Azure AD privileged roles
- ✅ **Account Status Validation** - Identifies disabled accounts with active permissions
- ✅ **Stale Account Detection** - Flags accounts inactive for 90+ days
- ✅ **Guest User Analysis** - Highlights external users with admin roles
- ✅ **Account Type Classification** - Distinguishes between user, service, and synced accounts
- ✅ **Nested Group Mapping** - Shows full permission inheritance chains
- ✅ **PIM Integration** - Identifies PIM-eligible vs. permanent assignments

### Reporting & Output
- ✅ **Detailed CSV Export** - Complete data for deep analysis
- ✅ **Executive Summary** - High-level findings and recommendations
- ✅ **Issue Categorization** - Prioritized by severity (Critical, High, Medium)
- ✅ **Actionable Recommendations** - Specific remediation steps for each finding
- ✅ **Audit Trail** - Timestamped reports for compliance documentation

### Automation & Integration
- ✅ **Scheduled Execution** - Run monthly audits automatically
- ✅ **Zero Configuration** - Works out-of-the-box with Microsoft Graph
- ✅ **Read-Only Operations** - Safe to run in production (no changes made)
- ✅ **Scalable** - Handles tenants of any size

---

## 💼 Use Cases

### IT Security Teams
- Monthly privileged access reviews
- Incident response investigations
- Security posture assessments
- Compliance audit preparation

### IT Administrators
- Onboarding/offboarding verification
- License optimization
- Access governance
- Role hygiene maintenance

### Compliance Officers
- SOC 2 / ISO 27001 evidence collection
- Privileged access documentation
- Risk assessment reporting
- Audit trail generation

### MSPs / Consultants
- Client security assessments
- Pre-engagement reconnaissance
- Ongoing monitoring services
- Security maturity benchmarking

---

##  Prerequisites

### Required
- **PowerShell:** Version 5.1 or PowerShell 7+
- **Microsoft Graph PowerShell SDK:** Version 2.0 or higher
- **Azure AD Permissions:** One of the following:
  - Global Reader
  - Security Reader
  - Privileged Role Administrator (read-only)

### Optional (for advanced features)
- **Privileged Identity Management (PIM):** For PIM-eligibility checking
- **Azure AD Premium P2:** For sign-in activity data

### Supported Environments
- ✅ Windows 10/11
- ✅ Windows Server 2016+
- ✅ macOS (PowerShell 7)
- ✅ Linux (PowerShell 7)

---

##  Installation

### Step 1: Install Microsoft Graph PowerShell Module

```powershell
# Install for all users (requires admin)
Install-Module Microsoft.Graph -Scope AllUsers -Force

# Or install for current user only
Install-Module Microsoft.Graph -Scope CurrentUser -Force
```

### Step 2: Clone This Repository

```bash
git clone https://github.com/yourusername/azure-ad-privileged-role-audit.git
cd azure-ad-privileged-role-audit
```

### Step 3: Verify Installation

```powershell
# Check PowerShell version
$PSVersionTable.PSVersion

# Verify Microsoft Graph module
Get-Module Microsoft.Graph -ListAvailable
```

---

##  Usage

### Quick Start

```powershell
# Navigate to script directory
cd C:\SecurityAudits\AzureAD_PrivilegedRoles

# Run the audit
.\AzureAD-PrivilegedRoleAudit.ps1
```

### What Happens:
1. Browser opens for authentication
2. Sign in with your Azure AD admin account
3. Consent to required permissions (one-time)
4. Script scans all privileged roles
5. Reports generated automatically

### Expected Runtime
- **Small tenant** (< 100 users): 2-3 minutes
- **Medium tenant** (100-1,000 users): 3-5 minutes
- **Large tenant** (1,000+ users): 5-10 minutes

### Authentication

The script requires these Microsoft Graph API permissions (read-only):
- `Directory.Read.All`
- `RoleManagement.Read.All`
- `User.Read.All`
- `AuditLog.Read.All`

---

##  What It Audits

### Privileged Roles Checked

| Role | Risk Level | Description |
|------|-----------|-------------|
| Global Administrator | **CRITICAL** | Full access to all Azure AD and Microsoft 365 services |
| Privileged Role Administrator | **CRITICAL** | Can manage role assignments |
| Security Administrator | **HIGH** | Manages security features and policies |
| User Administrator | **HIGH** | Can manage users and groups |
| Exchange Administrator | **HIGH** | Full access to Exchange Online |
| SharePoint Administrator | **HIGH** | Full access to SharePoint and OneDrive |
| Compliance Administrator | **MEDIUM** | Manages compliance features |
| Helpdesk Administrator | **MEDIUM** | Can reset passwords for non-admins |
| Authentication Administrator | **HIGH** | Can manage authentication methods |
| Conditional Access Administrator | **HIGH** | Manages Conditional Access policies |
| Application Administrator | **MEDIUM** | Can manage enterprise applications |
| Cloud Application Administrator | **MEDIUM** | Can manage cloud applications |
| Intune Administrator | **HIGH** | Full access to Microsoft Intune |
| Teams Administrator | **MEDIUM** | Full access to Microsoft Teams |
| Billing Administrator | **MEDIUM** | Can manage purchases and subscriptions |
| Global Reader | **LOW** | Read-only access to everything |
| Privileged Authentication Administrator | **CRITICAL** | Can manage all authentication methods |

### Security Checks Performed

#### Account Status
- ✅ Disabled accounts with active role assignments
- ✅ Accounts that never signed in
- ✅ Stale accounts (90+ days inactive)

#### Account Type Analysis
- ✅ Guest/external users with admin roles
- ✅ Regular users vs. dedicated admin accounts
- ✅ Service accounts with inappropriate privileges
- ✅ Synced accounts as Global Administrators

#### Licensing & Compliance
- ✅ Unlicensed accounts with admin roles
- ✅ License optimization opportunities
- ✅ Over-privileged role assignments

#### Permission Inheritance
- ✅ Nested group memberships
- ✅ Hidden permission paths
- ✅ PIM eligibility status

---

## Output & Reports

### CSV Report
**Filename:** `AzureAD_PrivilegedRoleAudit_YYYYMMDD_HHMMSS.csv`

Contains detailed information for each privileged account:
- Role name and description
- User principal name and display name
- Account type and status
- Last sign-in date and activity
- Issues identified
- Membership path (for nested groups)

### Summary Report
**Filename:** `AzureAD_PrivilegedRoleAudit_Summary_YYYYMMDD_HHMMSS.txt`

Executive summary including:
- Total privileged accounts count
- Critical findings breakdown
- Global Administrators list
- Issue categorization
- Remediation recommendations
- Zero Trust principles alignment

### Sample Output

```
=====================================================
AZURE AD PRIVILEGED ROLE AUDIT SUMMARY
=====================================================
Audit Date: 2025-10-29 14:30:00
Tenant: Contoso Corporation

STATISTICS
-----------------------------------------------------
Total Privileged Accounts: 23
Total Issues Found: 7
Roles Audited: 17

CRITICAL FINDINGS
-----------------------------------------------------
• 2 disabled accounts still in privileged roles
• 1 guest user with administrative access
• 3 accounts never signed in with active permissions
• 4 regular users as Global Admins (should use separate accounts)
• 1 synced account as Global Administrator

RECOMMENDATIONS
-----------------------------------------------------
1. Remove disabled accounts from all privileged roles immediately
2. Revoke guest user admin access
3. Implement separate admin accounts for privileged access
4. Deploy Privileged Identity Management (PIM)
5. Limit Global Administrators to 2-5 break-glass accounts
=====================================================
```

---

##  Sample Findings

### Critical Finding #1: Disabled Account with Global Admin
**Issue:** Sarah Johnson's account is disabled but retains Global Administrator privileges

**Risk:** 
- Account could be re-enabled by attacker
- Violates least privilege principle
- Compliance violation

**Remediation:**
```powershell
# Remove user from Global Administrator role
Remove-MgDirectoryRoleMemberByRef -DirectoryRoleId <RoleId> -DirectoryObjectId <UserId>
```

### Critical Finding #2: Guest User with Admin Role
**Issue:** External consultant has Exchange Administrator privileges

**Risk:**
- External entity with internal system access
- No background check/vetting
- Potential data exfiltration vector

**Remediation:**
1. Remove admin role immediately
2. Assign guest user to limited scope
3. Implement Conditional Access for external users
4. Review guest access policy

### High Finding #3: Account Never Signed In
**Issue:** Mike Chen has User Administrator role but never logged in

**Risk:**
- Forgotten account = security blind spot
- May be a test/temp account
- License waste

**Remediation:**
1. Contact manager to verify need
2. If not needed, disable and remove role
3. If needed, require first login within 7 days

---

## 🛠️ Remediation Guide

### Immediate Actions (Week 1)

#### 1. Remove Disabled Accounts from Roles
```powershell
# List disabled accounts with roles
Get-MgUser -Filter "accountEnabled eq false" | 
  Where-Object { (Get-MgUserMemberOf -UserId $_.Id).Count -gt 0 }

# Remove from specific role
Remove-MgDirectoryRoleMemberByRef -DirectoryRoleId <RoleId> -DirectoryObjectId <UserId>
```

#### 2. Revoke Guest User Admin Access
```powershell
# Find guest users with admin roles
Get-MgUser -Filter "userType eq 'Guest'" | 
  ForEach-Object { Get-MgUserMemberOf -UserId $_.Id }
```

#### 3. Investigate Never-Signed-In Accounts
```powershell
# Check account details
Get-MgUser -UserId <UserPrincipalName> -Property SignInActivity, CreatedDateTime
```

### Short-Term Actions (Month 1)

#### 4. Implement Separate Admin Accounts
**Best Practice:** Users should have two accounts:
- Regular account: `john.smith@company.com` (daily work)
- Admin account: `admin-jsmith@company.com` (privileged tasks only)

#### 5. Reduce Global Administrator Count
**Target:** 2-5 break-glass accounts maximum
**Current best practice:** Only emergency access accounts should be permanent Global Admins

#### 6. Enable MFA for All Admin Accounts
```powershell
# Check MFA status
Get-MgUser -All | Select-Object UserPrincipalName, 
  @{Name="MFAStatus";Expression={$_.StrongAuthenticationMethods}}
```

### Long-Term Actions (Quarter 1)

#### 7. Deploy Privileged Identity Management (PIM)
- Just-in-time admin access
- Time-bound role activations
- Approval workflows
- Audit trail

#### 8. Implement Conditional Access Policies
- Require MFA for admin roles
- Restrict admin sign-ins by location
- Block legacy authentication
- Require compliant devices

#### 9. Automate Monthly Audits
```powershell
# Create scheduled task (Windows)
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' `
  -Argument '-ExecutionPolicy Bypass -File "C:\SecurityAudits\AzureAD_PrivilegedRoles\AzureAD-PrivilegedRoleAudit.ps1"'

$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 8am

Register-ScheduledTask -TaskName "Azure AD Privileged Role Audit" `
  -Action $Action -Trigger $Trigger -Description "Monthly security audit"
```

---

##  Security Best Practices

### Microsoft Zero Trust Principles

#### 1. Verify Explicitly
- ✅ Always authenticate and authorize based on all available data points
- ✅ Require MFA for all admin accounts (no exceptions)
- ✅ Use risk-based authentication

#### 2. Use Least Privileged Access
- ✅ Assign minimum permissions needed
- ✅ Just-in-time access via PIM
- ✅ Time-bound role assignments
- ✅ Separate admin accounts

#### 3. Assume Breach
- ✅ Monitor all privileged account activity
- ✅ Audit logs for anomalies
- ✅ Implement detection and response
- ✅ Regular access reviews

### CIS Microsoft 365 Foundations Benchmark Alignment

This tool helps achieve compliance with:
- **CIS Control 1.1.1:** Ensure administrative accounts are separate from regular accounts
- **CIS Control 1.1.2:** Ensure modern authentication for Exchange Online is enabled
- **CIS Control 1.1.3:** Ensure that between two and four global admins are designated
- **CIS Control 1.2.1:** Ensure MFA is required for administrative roles

---

##  Roadmap

### Version 2.0 (Planned)
- [ ] Email notifications for critical findings
- [ ] Integration with Microsoft Sentinel
- [ ] Automated remediation workflows
- [ ] Comparison reports (month-over-month trends)
- [ ] Custom role definition support
- [ ] Multi-tenant support for MSPs

### Version 3.0 (Future)
- [ ] Web dashboard for visualization
- [ ] Real-time monitoring mode
- [ ] Machine learning for anomaly detection
- [ ] Integration with ticketing systems
- [ ] Mobile app for alerts
- [ ] API for external integrations

---

##  Contributing

Contributions are welcome! Please follow these guidelines:



---


---

---



---


