# Connect to Microsoft Graph for user management
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

Write-Host "`nCreating Test Users for Azure AD Security Audit Demo..." -ForegroundColor Cyan

# Get your domain name
$domain = (Get-MgDomain | Where-Object {$_.IsDefault -eq $true}).Id
Write-Host "Using domain: $domain" -ForegroundColor Yellow

# Scenario 1: Active Global Admin (GOOD - but we'll flag it as regular user)
$user1 = @{
    AccountEnabled = $true
    DisplayName = "Ibukunoluwa Sulaiman"
    MailNickname = "isulaiman"
    UserPrincipalName = "ibukun.sulaiman@$aiderapp.com"
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $false
        Password = "TestPass123!"
    }
}

# Scenario 2: Disabled account that still has admin role (BAD - major finding!)
$user2 = @{
    AccountEnabled = $false
    DisplayName = "Peace Ayuba- DISABLED"
    MailNickname = "payuba"
    UserPrincipalName = "payuba@ibukunsulaimanaiderapp.onmicrosoft.com"
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $false
        Password = "TestPass123!"
    }
}

# Scenario 3: Account never signed in but has admin role (BAD - stale account)
$user3 = @{
    AccountEnabled = $true
    DisplayName = "Ahmed Salvador - Never Used"
    MailNickname = "asalvador"
    UserPrincipalName = "asalvador@ibukunsulaimanaiderapp.onmicrosoft.com"
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $false
        Password = "TestPass123!"
    }
}

# Scenario 4: Service account pattern (for identification)
$user4 = @{
    AccountEnabled = $true
    DisplayName = "SVC-BackupAdmin"
    MailNickname = "svc-backup"
    UserPrincipalName = "svc_backup@ibukunsulaimanaiderapp.onmicrosoft.com"
    PasswordProfile = @{
        ForceChangePasswordNextSignIn = $false
        Password = "TestPass123!"
    }
}

# Create the users
Write-Host "`nCreating test users..." -ForegroundColor Yellow

try {
    $newUser1 = New-MgUser -BodyParameter $user1
    Write-Host "✓ Created: Ibukunoluwa Sulaiman (Regular Admin)" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error creating Ibukunoluwa sulaiman: $_" -ForegroundColor Red
}

try {
    $newUser2 = New-MgUser -BodyParameter $user2
    Write-Host "✓ Created: Peace Ayuba (DISABLED - This will be a finding!)" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error creating Peace ayuba: $_" -ForegroundColor Red
}

try {
    $newUser3 = New-MgUser -BodyParameter $user3
    Write-Host "✓ Created: Ahmed Salvador (Never signed in - Will be flagged)" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error creating Ahmed Salvador: $_" -ForegroundColor Red
}

try {
    $newUser4 = New-MgUser -BodyParameter $user4
    Write-Host "✓ Created: SVC-BackupAdmin (Service Account)" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error creating Service Account: $_" -ForegroundColor Red
}

Write-Host "`nTest users created successfully!" -ForegroundColor Cyan
Write-Host "`nNext: We'll assign admin roles to create realistic findings..." -ForegroundColor Yellow
