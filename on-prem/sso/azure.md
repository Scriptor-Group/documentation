# Azure AD SSO Configuration

Configure Microsoft Azure Active Directory (Entra ID) authentication for your Devana.ai whitemark instance. This provider supports both cloud-based Azure AD and on-premises Active Directory Federation Services (ADFS).

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `AZURE_AD_CLIENT_ID` | Application (client) ID from Azure AD | Yes | `12345678-1234-1234-1234-123456789012` |
| `AZURE_AD_CLIENT_SECRET` | Client secret from Azure AD | Yes | `your-client-secret` |
| `AZURE_AD_REDIRECT_URL` | Redirect URI for authentication | Yes | `https://your-domain.com/auth/azuread/callback` |
| `AZURE_AD_TENANT_ID` | Azure AD tenant ID (cloud only) | Cloud: Yes | `87654321-4321-4321-4321-210987654321` |
| `AZURE_AD_ON_PREM_URL` | ADFS metadata URL (on-prem only) | On-prem: Yes | `https://adfs.yourcompany.com/.well-known/openid-configuration` |
| `AZURE_AD_SCOPES` | Comma-separated list of scopes | No | `profile,offline_access,email,User.Read` |

## Setup Instructions

### Option A: Cloud Azure AD Setup

1. **Register Application in Azure Portal:**
   - Go to [Azure Portal](https://portal.azure.com)
   - Navigate to "Azure Active Directory" ’ "App registrations"
   - Click "New registration"
   - Configure:
     - **Name**: `Devana.ai SSO`
     - **Supported account types**: Accounts in this organizational directory only
     - **Redirect URI**: Web - `https://your-domain.com/auth/azuread/callback`

2. **Configure Application:**
   - Note the **Application (client) ID** (`AZURE_AD_CLIENT_ID`)
   - Note the **Directory (tenant) ID** (`AZURE_AD_TENANT_ID`)
   - Go to "Certificates & secrets" ’ "Client secrets"
   - Create a new client secret (`AZURE_AD_CLIENT_SECRET`)

3. **API Permissions (Optional for roles):**
   - Go to "API permissions"
   - Add permissions:
     - **Microsoft Graph**: `User.Read` (for basic profile)
     - **Microsoft Graph**: `Directory.Read.All` (for roles/groups)
   - Grant admin consent for the organization

### Option B: On-Premises ADFS Setup

1. **Configure ADFS Application:**
   - Open ADFS Management Console
   - Navigate to "Application Groups"
   - Create new application group for web application and web API
   - Configure redirect URI: `https://your-domain.com/auth/azuread/callback`

2. **Get Metadata URL:**
   - The metadata URL follows the pattern:
   - `https://your-adfs-server/.well-known/openid-configuration`

### 3. Environment Configuration

**For Cloud Azure AD:**
```env
# Azure AD Cloud Configuration
AZURE_AD_CLIENT_ID=12345678-1234-1234-1234-123456789012
AZURE_AD_CLIENT_SECRET=your-client-secret
AZURE_AD_REDIRECT_URL=https://your-domain.com/auth/azuread/callback
AZURE_AD_TENANT_ID=87654321-4321-4321-4321-210987654321

# Optional: Custom scopes (defaults to profile,offline_access,email)
AZURE_AD_SCOPES=profile,offline_access,email,User.Read,Directory.Read.All
```

**For On-Premises ADFS:**
```env
# Azure AD On-Premises Configuration
AZURE_AD_CLIENT_ID=your-adfs-client-id
AZURE_AD_CLIENT_SECRET=your-adfs-client-secret
AZURE_AD_REDIRECT_URL=https://your-domain.com/auth/azuread/callback
AZURE_AD_ON_PREM_URL=https://adfs.yourcompany.com/.well-known/openid-configuration

# Optional: Custom scopes
AZURE_AD_SCOPES=profile,offline_access,email
```

### 4. Whitemark Configuration

Configure your whitemark to include Azure AD as an allowed provider:

```json
{
  "allowedProviders": ["AZUREAD"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User clicks "Sign in with Microsoft" button
2. User is redirected to Azure AD/ADFS authorization endpoint
3. User authenticates with their Microsoft credentials
4. Azure AD redirects back to your callback URL with authorization code
5. Application exchanges code for access token and ID token
6. Application optionally fetches user roles from Microsoft Graph API
7. User is created/updated in Devana.ai and logged in

## User Data Mapping

Azure AD provides comprehensive user information:

| Azure AD Field | Devana.ai Field | Notes |
|----------------|-----------------|-------|
| `email` | `email` | Primary identifier |
| `given_name` | `firstName` | First name |
| `family_name` | `lastName` | Last name |
| `name` | `displayName` | Full name |
| `oid` | `providerId` | Unique user identifier |

## Role/Group Integration

When configured with appropriate scopes (`User.Read` + `Directory.Read.All`), the system can fetch user roles:

### Cloud Azure AD Roles
- Fetches directory roles from Microsoft Graph API
- Requires `Directory.Read.All` or `Directory.AccessAsUser.All` permissions
- Roles are logged but not currently used for authorization

### Configuration for Role Retrieval
```env
AZURE_AD_SCOPES=profile,offline_access,email,User.Read,Directory.Read.All
```

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains
- **Token Validation**: Full OIDC token validation in production environments
- **HTTPS Enforcement**: Production environments require HTTPS for redirect URLs

## Advanced Configuration

### Custom Scopes

Default scopes: `profile`, `offline_access`, `email`

Common additional scopes:
- `User.Read`: Basic profile information
- `Directory.Read.All`: Read directory data including roles
- `Directory.AccessAsUser.All`: Access directory as signed-in user

### Environment-Specific Settings

The provider automatically adjusts behavior based on `NODE_ENV`:

**Development:**
- `allowHttpForRedirectUrl: true`
- `validateIssuer: false`

**Production:**
- `allowHttpForRedirectUrl: false`
- `validateIssuer: true`

## Troubleshooting

### Common Issues

**AADSTS50011: Redirect URI mismatch**
- Ensure `AZURE_AD_REDIRECT_URL` exactly matches the registered redirect URI
- URLs are case-sensitive and must include protocol (https://)

**AADSTS70001: Application not found**
- Verify `AZURE_AD_CLIENT_ID` is correct
- Ensure the application is properly registered in the correct tenant

**AADSTS7000215: Invalid client secret**
- Check that `AZURE_AD_CLIENT_SECRET` is correct and not expired
- Client secrets have expiration dates in Azure AD

**Invalid issuer**
- For cloud: Verify `AZURE_AD_TENANT_ID` is correct
- For on-prem: Verify `AZURE_AD_ON_PREM_URL` points to correct ADFS server

**Failed to fetch user roles**
- Ensure required permissions are granted and admin consent provided
- Check that `User.Read` and `Directory.Read.All` scopes are included
- Verify the access token has sufficient permissions

### Testing

1. Enable Azure AD SSO in your whitemark configuration
2. Navigate to your login page  
3. Click "Sign in with Microsoft"
4. Complete authentication with an Azure AD account
5. Verify user is created and logged in successfully
6. Check logs for role information if configured

### Debug Information

The system logs detailed information including:
- Retrieved user roles (when configured)
- Authentication errors with specific error codes
- Token validation results

## Best Practices

- Use HTTPS for all redirect URIs in production
- Regularly rotate client secrets before expiration
- Monitor authentication logs for failed attempts
- Use least-privilege principle for API permissions
- Keep ADFS servers updated with latest security patches
- Consider using certificate-based authentication for higher security