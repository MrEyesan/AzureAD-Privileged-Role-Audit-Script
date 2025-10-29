# Contributing to Azure AD Privileged Role Audit Tool

First off, thank you for considering contributing to this project! 🎉

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected vs actual behavior**
- **PowerShell version** (`$PSVersionTable.PSVersion`)
- **Module versions** (`Get-Module Microsoft.Graph -ListAvailable`)
- **Error messages** (full text)
- **Screenshots** if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating one:

- **Use a clear title**
- **Describe the current behavior**
- **Explain the expected behavior**
- **Explain why** this enhancement would be useful

### Pull Requests

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

#### Pull Request Guidelines

- **Update documentation** if needed
- **Add tests** for new features
- **Follow PowerShell best practices**
- **Use descriptive commit messages**
- **Keep PRs focused** on a single feature/fix

## Development Setup
```powershell
# Clone your fork
git clone https://github.com/your-username/azure-ad-privileged-role-audit.git
cd azure-ad-privileged-role-audit

# Create a branch
git checkout -b feature/your-feature-name

# Make your changes
# Test thoroughly

# Commit and push
git add .
git commit -m "Description of changes"
git push origin feature/your-feature-name
```

## Coding Standards

### PowerShell Style Guide

- Use **Verb-Noun** naming (e.g., `Get-PrivilegedRoles`)
- Use **PascalCase** for function names
- Use **camelCase** for variables
- Include **comment-based help** for all functions
- Use **approved verbs** (`Get-Verb` to see list)

### Example Function Template
```powershell
function Get-ExampleFunction {
    <#
    .SYNOPSIS
        Brief description
    
    .DESCRIPTION
        Detailed description
    
    .PARAMETER ParameterName
        Description of parameter
    
    .EXAMPLE
        Get-ExampleFunction -ParameterName "value"
        
    .NOTES
        Author: Your Name
        Version: 1.0
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ParameterName
    )
    
    begin {
        Write-Verbose "Starting function"
    }
    
    process {
        # Main logic here
    }
    
    end {
        Write-Verbose "Function complete"
    }
}
```

## Testing

Before submitting a PR, test your changes:
```powershell
# Run prerequisite tests
.\tests\Test-Prerequisites.ps1

# Test connectivity
.\tests\Test-Connection.ps1

# Run the main script
.\scripts\AzureAD-PrivilegedRoleAudit.ps1
```

## Documentation

If you add new features, update:
- README.md
- INSTALLATION.md
- USAGE.md
- Inline code comments
- Example files

## Questions?

Open an issue labeled "question" or reach out via email.

Thank you for contributing! 🚀
