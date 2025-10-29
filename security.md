# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please:

1. **Do NOT** open a public issue
2. Email security details to: your.eyesanjemine@yahoo.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Response Timeline

- **Initial response:** Within 48 hours
- **Status update:** Within 7 days
- **Fix timeline:** Depends on severity
  - Critical: 1-3 days
  - High: 1-2 weeks
  - Medium: 2-4 weeks
  - Low: Next planned release

## Security Best Practices

When using this tool:

### Do's ✅
- Run with minimum required permissions
- Review audit logs regularly
- Keep Microsoft Graph module updated
- Use MFA for admin accounts
- Store reports securely

### Don'ts ❌
- Don't share authentication tokens
- Don't run with more permissions than needed
- Don't store credentials in scripts
- Don't disable security warnings
- Don't bypass certificate validation

## Known Security Considerations

### Authentication
- Uses OAuth 2.0 delegated permissions
- Requires user interaction (device code or browser)
- Tokens cached by Microsoft.Graph module
- Token lifetime: 1 hour (managed by Azure AD)

### Data Handling
- Reports contain sensitive privileged user data
- CSV files should be encrypted at rest
- Secure deletion recommended
- Do not commit reports to version control

### Network Security
- All connections use HTTPS
- Communication with Microsoft Graph API only
- No third-party services contacted
- Respect corporate proxy settings

## Security Features

- ✅ Read-only operations
- ✅ No credential storage
- ✅ Audit trail in Azure AD logs
- ✅ Delegated permissions only
- ✅ No application secrets required
- ✅ Token managed by Microsoft

## Compliance

This tool aids compliance with:
- **NIST Cybersecurity Framework**
- **CIS Microsoft 365 Foundations Benchmark**
- **ISO 27001** (privileged access management)
- **SOC 2** (access reviews)

## Updates

Security updates will be released as:
- Patch versions (1.0.x) for security fixes
- Announced via GitHub Security Advisories
- Detailed in CHANGELOG.md

---

