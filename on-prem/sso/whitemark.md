# Whitemark SSO Configuration

This document explains how to configure SSO providers and registration types at the whitemark level in Devana.ai.

## Overview

Each whitemark instance in Devana.ai can be configured with specific SSO settings that control:
- Which authentication providers are available to users
- What types of registration/authentication are allowed
- Automatic redirection behavior for single-provider setups

## Configuration Properties

### allowedProviders

An array of SSO providers that are enabled for the whitemark.

**Available Providers:**
- `APPLE` - Apple ID authentication
- `AUTHENTIK` - Authentik identity provider
- `AZUREAD` - Microsoft Azure AD / Entra ID
- `GITHUB` - GitHub OAuth
- `GOOGLE` - Google OAuth
- `LDAP` - LDAP directory authentication
- `OAUTH2` - Generic OAuth 2.0 provider
- `OPENID_CONNECT` - OpenID Connect provider

**Example:**
```json
{
  "allowedProviders": ["AZUREAD", "GOOGLE", "GITHUB"]
}
```

### registrationType

An array of authentication methods allowed for the whitemark.

**Available Types:**
- `CREDENTIALS` - Traditional email/password authentication
- `SSO` - Single Sign-On authentication

**Example:**
```json
{
  "registrationType": ["SSO", "CREDENTIALS"]
}
```

## Configuration Examples

### 1. Mixed Authentication (SSO + Credentials)

Allow both SSO and traditional login:

```json
{
  "allowedProviders": ["AZUREAD", "GOOGLE"],
  "registrationType": ["SSO", "CREDENTIALS"]
}
```

**Behavior:**
- Users see both SSO provider buttons and email/password form
- Users can choose their preferred authentication method
- New users can register with either method

### 2. SSO-Only Authentication

Disable traditional login, allow multiple SSO providers:

```json
{
  "allowedProviders": ["AZUREAD", "GOOGLE", "GITHUB"],
  "registrationType": ["SSO"]
}
```

**Behavior:**
- Users only see SSO provider buttons
- Email/password form is hidden
- All authentication goes through SSO providers

### 3. Single Provider Auto-Redirect

Single SSO provider with automatic redirection:

```json
{
  "allowedProviders": ["AZUREAD"],
  "registrationType": ["SSO"]
}
```

**Behavior:**
- Users are automatically redirected to Azure AD login
- No provider selection screen is shown
- Streamlined authentication experience

### 4. Credentials-Only (No SSO)

Traditional authentication only:

```json
{
  "allowedProviders": [],
  "registrationType": ["CREDENTIALS"]
}
```

**Behavior:**
- Only email/password authentication available
- No SSO provider buttons shown
- Users must register with email/password

## Configuration Methods

### GraphQL Mutations

#### setupSsoProviders

Configure SSO providers for a whitemark:

```graphql
mutation SetupSsoProviders($whitemarkId: ID!, $allowedProviders: [AuthProvidersTypeEnum!]!, $registrationType: [RegistrationTypeEnum!]) {
  setupSsoProviders(whitemarkId: $whitemarkId, allowedProviders: $allowedProviders, registrationType: $registrationType) {
    id
    allowedProviders
    registrationType
  }
}
```

**Variables:**
```json
{
  "whitemarkId": "whitemark-uuid",
  "allowedProviders": ["AZUREAD", "GOOGLE"],
  "registrationType": ["SSO", "CREDENTIALS"]
}
```

#### upsertWhitemark

Update whitemark with SSO configuration:

```graphql
mutation UpsertWhitemark($id: ID, $allowedProviders: [AuthProvidersTypeEnum], $registrationType: [RegistrationTypeEnum]) {
  upsertWhitemark(id: $id, allowedProviders: $allowedProviders, registrationType: $registrationType) {
    id
    allowedProviders
    registrationType
  }
}
```

### Admin Interface

The setup page (`/setup`) provides a user interface for configuring SSO:

1. **Provider Selection:**
   - Toggle switches for each available provider
   - Only enabled providers are shown to users

2. **Registration Type:**
   - Checkbox for enabling SSO authentication
   - Checkbox for enabling traditional credentials

3. **Live Preview:**
   - Shows how the login page will appear to users
   - Updates dynamically as configuration changes

## Authentication Flow Logic

### Provider Validation

When a user attempts to authenticate:

1. **Domain Matching:**
   ```typescript
   const whitemark = await prisma.whiteMark.findFirst({
     where: {
       domains: {
         hasSome: [origin],
       },
     },
   });
   ```

2. **Provider Authorization:**
   - Check if the requested provider is in `allowedProviders`
   - Reject authentication if provider not allowed

3. **Registration Type Check:**
   - Verify that `SSO` is in `registrationType` for SSO authentication
   - Verify that `CREDENTIALS` is in `registrationType` for email/password

### Auto-Redirect Logic

Automatic redirection occurs when:
- `registrationType` contains only `["SSO"]`
- `allowedProviders` contains exactly one provider

```typescript
if (
  whiteMark.registrationType.length === 1 &&
  whiteMark.registrationType[0] === RegistrationTypeEnum.Sso &&
  whiteMark.allowedProviders.length === 1
) {
  // Auto-redirect to single SSO provider
  router.push(
    `${process.env.NEXT_PUBLIC_SSO_API_URL}/auth/prepare?origin=${domain}&provider=${provider}`
  );
}
```

## Environment Requirements

Each enabled SSO provider requires specific environment variables to be configured. Refer to the individual provider documentation:

- [Apple Configuration](./apple.md)
- [Authentik Configuration](./authentik.md)
- [Azure AD Configuration](./azure.md)
- [GitHub Configuration](./github.md)
- [Google Configuration](./google.md)
- [LDAP Configuration](./ldap.md)
- [OAuth2 Configuration](./oauth2.md)
- [OIDC Configuration](./oidc.md)

## Domain Configuration

### Whitemark Domains

Each whitemark must have configured domains that match the authentication origin:

```json
{
  "domains": ["app.yourcompany.com", "yourcompany.devana.ai"]
}
```

### Authentication Origin

The system determines the whitemark by matching the request origin against configured domains:

```typescript
const origin = req.session?.authOrigin || req.headers?.["x-forwarded-host"];
```

## Security Considerations

### CSRF Protection

All SSO providers implement CSRF protection using state parameters:

```typescript
// Generate unique state for each authentication request
req.session.authState = uuidv4();

// Validate state parameter in callback
if (req.query.state && req.query.state !== expectedState) {
  return done(new Error("Invalid state parameter"));
}
```

### Session Management

Authentication sessions are managed securely:

```typescript
// Store authentication context in session
req.session.authOrigin = origin;
req.session.authProvider = provider;
req.session.authState = state;

// Clean up after successful authentication
delete req.session.authOrigin;
delete req.session.authProvider;
delete req.session.authState;
```

### Domain Validation

Each authentication is tied to a specific whitemark:

- Request origin must match a configured whitemark domain
- Users can only authenticate within their organization's whitemark
- Cross-whitemark authentication is prevented

## Troubleshooting

### Common Configuration Issues

**No whitemark found:**
- Verify domain is configured in whitemark settings
- Check that request origin matches configured domains
- Ensure proper handling of subdomains and protocols

**Provider not available:**
- Check that provider is included in `allowedProviders`
- Verify provider-specific environment variables are set
- Confirm provider configuration is valid

**Registration type mismatch:**
- Verify `registrationType` includes appropriate values
- Check that SSO is enabled for SSO authentication
- Ensure credentials are enabled for email/password authentication

### Debug Information

Enable debug logging to see:
- Whitemark resolution process
- Provider validation results
- Authentication flow progression
- Configuration values being used

## Best Practices

### Security
1. **Regularly audit** whitemark configurations
2. **Monitor authentication logs** for unauthorized attempts
3. **Use HTTPS** for all authentication endpoints
4. **Implement rate limiting** on authentication endpoints

### User Experience
1. **Test all provider combinations** before deployment
2. **Provide clear error messages** for configuration issues
3. **Consider auto-redirect** for single-provider scenarios
4. **Document authentication options** for users

### Maintenance
1. **Keep provider configurations updated** with latest settings
2. **Monitor provider service status** and plan for outages
3. **Test authentication flows** after configuration changes
4. **Backup whitemark configurations** before major changes

## Migration Scenarios

### Adding New SSO Providers

1. **Configure environment variables** for new provider
2. **Update whitemark configuration** to include new provider
3. **Test authentication flow** with new provider
4. **Communicate changes** to users

### Disabling SSO Providers

1. **Ensure alternative authentication** methods are available
2. **Notify users** before disabling providers
3. **Update whitemark configuration** to remove provider
4. **Monitor for authentication failures** after change

### Changing Registration Types

1. **Plan migration strategy** for existing users
2. **Test all affected authentication flows**
3. **Update user documentation** as needed
4. **Implement gradually** with rollback plan