# Authentik SSO Configuration

Configure Authentik authentication for your Devana.ai whitemark instance. Authentik is an open-source identity provider that supports OAuth2 and OpenID Connect.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `AUTHENTIK_CLIENT_ID` | OAuth2 Client ID from Authentik | Yes | `your-client-id` |
| `AUTHENTIK_CLIENT_SECRET` | OAuth2 Client Secret from Authentik | Yes | `your-client-secret` |
| `AUTHENTIK_CALLBACK_URL` | Callback URL for authentication | Yes | `https://your-domain.com/auth/authentik/callback` |
| `AUTHENTIK_URL` | Base URL of your Authentik instance | Yes | `https://auth.yourcompany.com` |
| `AUTHENTIK_USERINFO_URL` | UserInfo endpoint URL (optional) | No | `https://auth.yourcompany.com/application/o/userinfo/` |

## Setup Instructions

### 1. Authentik Application Setup

1. **Access Authentik Admin Interface:**
   - Log in to your Authentik instance as an administrator
   - Navigate to "Applications" ’ "Applications"

2. **Create OAuth2/OpenID Provider:**
   - Go to "Applications" ’ "Providers"
   - Click "Create" and select "OAuth2/OpenID Provider"
   - Configure the following settings:
     - **Name**: `Devana.ai SSO`
     - **Client Type**: `Confidential`
     - **Client ID**: Generate or set custom ID (this becomes `AUTHENTIK_CLIENT_ID`)
     - **Client Secret**: Generate secret (this becomes `AUTHENTIK_CLIENT_SECRET`)
     - **Redirect URIs**: Add your callback URL
     - **Scopes**: Include `openid`, `profile`, `email`, `offline_access`

3. **Create Application:**
   - Go to "Applications" ’ "Applications"
   - Click "Create" and configure:
     - **Name**: `Devana.ai`
     - **Slug**: `devana-ai`
     - **Provider**: Select the provider created above
     - **Launch URL**: Your application URL

### 2. Environment Configuration

Add the following variables to your environment configuration:

```env
# Authentik OAuth Configuration
AUTHENTIK_CLIENT_ID=your-client-id
AUTHENTIK_CLIENT_SECRET=your-client-secret
AUTHENTIK_CALLBACK_URL=https://your-domain.com/auth/authentik/callback
AUTHENTIK_URL=https://auth.yourcompany.com

# Optional: Custom UserInfo URL
AUTHENTIK_USERINFO_URL=https://auth.yourcompany.com/application/o/userinfo/
```

### 3. Whitemark Configuration

Configure your whitemark to include Authentik as an allowed provider:

```json
{
  "allowedProviders": ["AUTHENTIK"],
  "registrationType": ["SSO"]
}
```

## Authentication Endpoints

The system automatically constructs the following endpoints:

- **Authorization URL**: `{AUTHENTIK_URL}/application/o/authorize/`
- **Token URL**: `{AUTHENTIK_URL}/application/o/token/`
- **UserInfo URL**: `{AUTHENTIK_USERINFO_URL}` or `{AUTHENTIK_URL}/application/o/userinfo/`

## Authentication Flow

1. User clicks "Sign in with Authentik" button
2. User is redirected to Authentik's authorization endpoint
3. User authenticates with their Authentik credentials
4. Authentik redirects back to your callback URL with authorization code
5. Application exchanges code for access token
6. Application fetches user profile from UserInfo endpoint
7. User is created/updated in Devana.ai and logged in

## User Data Mapping

Authentik provides comprehensive user information through OpenID Connect:

| Authentik Field | Devana.ai Field | Notes |
|-----------------|-----------------|-------|
| `email` | `email` | Primary identifier |
| `given_name` | `firstName` | First name |
| `family_name` | `lastName` | Last name |
| `middle_name` | - | Available but not mapped |
| `preferred_username` | - | Available but not mapped |
| `name` | `displayName` | Full name fallback |
| `sub` | `providerId` | Unique user identifier |
| `email_verified` | - | Email verification status |

## Scopes and Permissions

The application requests the following scopes:

- **`openid`**: Required for OpenID Connect
- **`profile`**: Access to profile information (name, username)
- **`email`**: Access to email address
- **`offline_access`**: Refresh token for long-term access

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains
- **Token Security**: Uses confidential client with client secret for token exchange

## Advanced Configuration

### Custom Scopes

If your Authentik instance provides custom scopes, you can request them by modifying the provider configuration. The default scopes are sufficient for most use cases.

### Group Mapping

Authentik can provide group information through claims. To utilize group-based access control:

1. Configure group claims in your Authentik provider
2. Modify the application to process group information from the token

### Custom Attributes

Authentik supports custom user attributes that can be included in the OIDC response. Configure these in your Authentik provider settings.

## Troubleshooting

### Common Issues

**Invalid client credentials:**
- Verify `AUTHENTIK_CLIENT_ID` and `AUTHENTIK_CLIENT_SECRET` are correct
- Ensure client type is set to "Confidential" in Authentik

**Redirect URI mismatch:**
- Callback URL must match exactly what's configured in Authentik
- URLs are case-sensitive and must include protocol (https://)

**Connection refused:**
- Verify `AUTHENTIK_URL` is accessible from your application server
- Check firewall rules and network connectivity

**Invalid scope:**
- Ensure all requested scopes are enabled in your Authentik provider
- Check that the provider includes the necessary scope mappings

**User profile fetch failed:**
- Verify `AUTHENTIK_USERINFO_URL` is correct or remove it to use default
- Check that the UserInfo endpoint is accessible with the access token

### Testing

1. Enable Authentik SSO in your whitemark configuration
2. Navigate to your login page
3. Click "Sign in with Authentik"
4. Complete authentication with an Authentik account
5. Verify user is created and logged in successfully

### Debug Logging

Enable debug logging to see detailed authentication flow:

```env
DEBUG=authentik:*
```

## Best Practices

- Use strong, randomly generated client secrets
- Regularly rotate client credentials
- Monitor authentication logs for suspicious activity
- Keep Authentik instance updated with latest security patches
- Use HTTPS for all endpoints in production environments