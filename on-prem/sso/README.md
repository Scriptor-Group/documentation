# SSO Configuration Guide

This documentation provides comprehensive guidance for setting up Single Sign-On (SSO) authentication with Devana.ai. The system supports multiple SSO providers and can be configured at the whitemark level to control user authentication methods.

## Overview

Devana.ai supports the following SSO providers:

- **[Apple](./apple.md)** - Apple ID authentication
- **[Authentik](./authentik.md)** - Open-source identity provider
- **[Azure AD](./azure.md)** - Microsoft Azure Active Directory / Entra ID
- **[GitHub](./github.md)** - GitHub OAuth authentication
- **[Google](./google.md)** - Google OAuth authentication
- **[LDAP](./ldap.md)** - Lightweight Directory Access Protocol
- **[OAuth2](./oauth2.md)** - Generic OAuth 2.0 provider
- **[OpenID Connect (OIDC)](./oidc.md)** - OpenID Connect provider

## Whitemark Configuration

Each whitemark instance can be configured with specific SSO settings:

### allowedProviders
Defines which SSO providers are permitted for the whitemark. Can include one or more of:
- `APPLE`
- `AUTHENTIK`
- `AZUREAD`
- `GITHUB`
- `GOOGLE`
- `LDAP`
- `OAUTH2`
- `OPENID_CONNECT`

### registrationType
Controls the authentication methods available:
- `CREDENTIALS` - Traditional email/password authentication
- `SSO` - Single Sign-On authentication only

### Configuration Examples

**Mixed Authentication (SSO + Credentials):**
```json
{
  "allowedProviders": ["AZUREAD", "GOOGLE"],
  "registrationType": ["SSO", "CREDENTIALS"]
}
```

**SSO-Only with Single Provider:**
```json
{
  "allowedProviders": ["AZUREAD"],
  "registrationType": ["SSO"]
}
```
*Note: This configuration will automatically redirect users to the Azure AD login.*

**Multiple SSO Providers:**
```json
{
  "allowedProviders": ["AZUREAD", "GOOGLE", "GITHUB"],
  "registrationType": ["SSO"]
}
```

## Setup Process

### 1. Configure Environment Variables
Each SSO provider requires specific environment variables. Refer to the individual provider documentation for details.

### 2. Configure Whitemark Settings
Use the admin interface or GraphQL mutations to configure:
- `allowedProviders`: Array of enabled SSO providers
- `registrationType`: Array of allowed authentication types

### 3. Test Authentication
Verify that users can successfully authenticate using the configured providers.

## Security Considerations

### CSRF Protection
All SSO providers implement CSRF protection using state parameters to prevent cross-site request forgery attacks.

### Session Management
- Authentication sessions are securely managed with proper cleanup
- State information is stored in server-side sessions, not cookies
- Session data is automatically cleaned up after successful authentication

### Domain Validation
Each SSO authentication is tied to a specific whitemark instance based on the domain, ensuring users authenticate within the correct organizational context.

## Troubleshooting

### Common Issues

**No whitemark found:**
- Verify that the domain is correctly configured in the whitemark settings
- Ensure the request origin matches one of the configured domains

**Invalid state parameter:**
- This indicates a potential CSRF attack or session timeout
- Users should retry the authentication process

**No email found in profile:**
- Some providers may not return email addresses in certain configurations
- Verify that the provider is configured to include email in the response
- Check that appropriate scopes are requested

### Debugging

Enable debug logging by setting appropriate log levels in your environment configuration. Authentication errors are logged with detailed information to help diagnose issues.

## Provider-Specific Documentation

For detailed setup instructions for each provider, see:

- [Apple SSO Setup](./apple.md)
- [Authentik SSO Setup](./authentik.md)
- [Azure AD SSO Setup](./azure.md)
- [GitHub SSO Setup](./github.md)
- [Google SSO Setup](./google.md)
- [LDAP SSO Setup](./ldap.md)
- [OAuth2 SSO Setup](./oauth2.md)
- [OpenID Connect SSO Setup](./oidc.md)
- [Whitemark Configuration](./whitemark.md)