# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Email notifications for critical findings
- Multi-tenant support
- Automated remediation workflows
- Web dashboard

## [1.0.0] - 2025-10-29

### Added
- Initial release
- Core audit functionality for 17 privileged roles
- CSV export with detailed findings
- Executive summary report generation
- Stale account detection (90+ days)
- Disabled account identification
- Guest user admin access detection
- Account type classification
- Nested group membership mapping
- PIM eligibility checking
- Comprehensive documentation
- Installation guide
- Usage examples

### Security
- Read-only operations only
- Delegated permissions (no app permissions)
- OAuth 2.0 authentication
- No credential storage

## [0.2.0] - 2025-10-15 (Beta)

### Added
- Beta testing release
- Basic role enumeration
- Simple CSV output

### Fixed
- Authentication flow improvements
- Error handling enhancements

## [0.1.0] - 2025-10-01 (Alpha)

### Added
- Proof of concept
- Connect to Microsoft Graph
- List Global Administrators

---

[Unreleased]: https://github.com/yourusername/azure-ad-privileged-role-audit/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/azure-ad-privileged-role-audit/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/yourusername/azure-ad-privileged-role-audit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/yourusername/azure-ad-privileged-role-audit/releases/tag/v0.1.0
