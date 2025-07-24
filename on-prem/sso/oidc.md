# OpenID Connect (OIDC) SSO Configuration

Configure OpenID Connect authentication for your Devana.ai whitemark instance. OIDC is an identity layer built on top of OAuth 2.0 that provides standardized user authentication and profile information.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `OIDC_ISSUER` | OIDC issuer identifier | Yes | `https://auth.yourcompany.com` |
| `OIDC_AUTHORIZATION_URL` | Authorization endpoint URL | Yes | `https://auth.yourcompany.com/auth` |
| `OIDC_TOKEN_URL` | Token endpoint URL | Yes | `https://auth.yourcompany.com/token` |
| `OIDC_USERINFO_URL` | UserInfo endpoint URL | Yes | `https://auth.yourcompany.com/userinfo` |
| `OIDC_CLIENT_ID` | OIDC Client ID | Yes | `devana-client-id` |
| `OIDC_CLIENT_SECRET` | OIDC Client Secret | Yes | `your-client-secret` |
| `OIDC_CALLBACK_URL` | Callback URL for authentication | Yes | `https://your-domain.com/auth/oidc/callback` |

## Setup Instructions

### 1. OIDC Provider Setup

The setup process varies by OIDC provider:

#### Generic OIDC Provider
1. **Create OIDC Client:**
   - Register a new client application in your OIDC provider
   - Set client type to "confidential" or "web application"
   - Configure redirect URI: `https://your-domain.com/auth/oidc/callback`

2. **Note Endpoint URLs:**
   - Most OIDC providers expose a discovery document at `/.well-known/openid-configuration`
   - Extract the required endpoint URLs from this document

#### Provider-Specific Examples

**Keycloak:**
```
Issuer: https://keycloak.yourcompany.com/auth/realms/master
Authorization URL: https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/auth
Token URL: https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/token
UserInfo URL: https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/userinfo
```

**Okta:**
```
Issuer: https://dev-123456.okta.com
Authorization URL: https://dev-123456.okta.com/oauth2/default/v1/authorize
Token URL: https://dev-123456.okta.com/oauth2/default/v1/token
UserInfo URL: https://dev-123456.okta.com/oauth2/default/v1/userinfo
```

### 2. Environment Configuration

Add the following variables to your environment configuration:

```env
# OpenID Connect Configuration
OIDC_ISSUER=https://auth.yourcompany.com
OIDC_AUTHORIZATION_URL=https://auth.yourcompany.com/auth
OIDC_TOKEN_URL=https://auth.yourcompany.com/token
OIDC_USERINFO_URL=https://auth.yourcompany.com/userinfo
OIDC_CLIENT_ID=devana-client-id
OIDC_CLIENT_SECRET=your-client-secret
OIDC_CALLBACK_URL=https://your-domain.com/auth/oidc/callback
```

### 3. Whitemark Configuration

Configure your whitemark to include OIDC as an allowed provider:

```json
{
  "allowedProviders": ["OPENID_CONNECT"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User clicks "Sign in with OIDC" button
2. User is redirected to the OIDC authorization endpoint
3. User authenticates with the OIDC provider
4. Provider redirects back to your callback URL with authorization code
5. Application exchanges code for ID token, access token, and refresh token
6. Application validates ID token and extracts user claims
7. Application fetches additional user info from UserInfo endpoint if needed
8. User is created/updated in Devana.ai and logged in

## User Data Mapping

OIDC provides standardized claims for user information:

| OIDC Claim | Devana.ai Field | Notes |
|------------|-----------------|-------|
| `email` | `email` | Primary identifier |
| `given_name` | `firstName` | First name |
| `family_name` | `lastName` | Last name |
| `name` | `displayName` | Full name |
| `sub` | `providerId` | Unique subject identifier |
| `preferred_username` | - | Username (available but not mapped) |
| `picture` | - | Profile picture URL (available but not mapped) |

## Standard OIDC Claims

OIDC defines standard claims that may be available:

### Profile Scope Claims
- `name`: Full name
- `family_name`: Last name
- `given_name`: First name
- `middle_name`: Middle name
- `nickname`: Casual name
- `preferred_username`: Username
- `profile`: Profile page URL
- `picture`: Profile picture URL
- `website`: Website URL
- `gender`: Gender
- `birthdate`: Birthday
- `zoneinfo`: Time zone
- `locale`: Locale
- `updated_at`: Last profile update

### Email Scope Claims
- `email`: Email address
- `email_verified`: Email verification status

### Address Scope Claims
- `address`: Physical mailing address

### Phone Scope Claims
- `phone_number`: Phone number
- `phone_number_verified`: Phone verification status

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains
- **ID Token Validation**: Cryptographic validation of ID tokens
- **Issuer Verification**: Validates token issuer matches expected provider

## Advanced Configuration

### Discovery Document

Most OIDC providers expose a discovery document. You can use it to automatically configure endpoints:

```bash
# Fetch discovery document
curl https://auth.yourcompany.com/.well-known/openid-configuration
```

### Custom Claims

OIDC providers may expose custom claims. To access them:

1. **Request Custom Scopes:**
   - Configure your OIDC client to request additional scopes
   - Custom scopes depend on your provider configuration

2. **Process Custom Claims:**
   - Modify the authentication callback to handle custom claims
   - Map custom claims to application-specific user attributes

### Token Validation

For enhanced security, implement additional token validation:

1. **Signature Verification:**
   - Verify ID token signature using provider's public keys
   - Check token expiration and not-before claims

2. **Audience Validation:**
   - Ensure token audience matches your client ID
   - Validate issuer matches expected provider

## Provider-Specific Configurations

### Keycloak
```env
OIDC_ISSUER=https://keycloak.yourcompany.com/auth/realms/master
OIDC_AUTHORIZATION_URL=https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/auth
OIDC_TOKEN_URL=https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/token
OIDC_USERINFO_URL=https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/userinfo
OIDC_CLIENT_ID=devana
OIDC_CLIENT_SECRET=your-keycloak-secret
OIDC_CALLBACK_URL=https://your-domain.com/auth/oidc/callback
```

### Okta
```env
OIDC_ISSUER=https://dev-123456.okta.com
OIDC_AUTHORIZATION_URL=https://dev-123456.okta.com/oauth2/default/v1/authorize
OIDC_TOKEN_URL=https://dev-123456.okta.com/oauth2/default/v1/token
OIDC_USERINFO_URL=https://dev-123456.okta.com/oauth2/default/v1/userinfo
OIDC_CLIENT_ID=your-okta-client-id
OIDC_CLIENT_SECRET=your-okta-secret
OIDC_CALLBACK_URL=https://your-domain.com/auth/oidc/callback
```

### Auth0
```env
OIDC_ISSUER=https://yourcompany.auth0.com/
OIDC_AUTHORIZATION_URL=https://yourcompany.auth0.com/authorize
OIDC_TOKEN_URL=https://yourcompany.auth0.com/oauth/token
OIDC_USERINFO_URL=https://yourcompany.auth0.com/userinfo
OIDC_CLIENT_ID=your-auth0-client-id
OIDC_CLIENT_SECRET=your-auth0-secret
OIDC_CALLBACK_URL=https://your-domain.com/auth/oidc/callback
```

## Troubleshooting

### Common Issues

**Invalid issuer:**
- Verify `OIDC_ISSUER` matches the issuer claim in tokens
- Ensure issuer URL is accessible and correct

**Endpoint not found:**
- Verify all endpoint URLs are correct and accessible
- Check discovery document for correct endpoint URLs
- Ensure provider supports the OpenID Connect specification

**Invalid client:**
- Verify `OIDC_CLIENT_ID` and `OIDC_CLIENT_SECRET` are correct
- Ensure client is registered in the OIDC provider
- Check client configuration (confidential vs. public)

**Token validation failed:**
- Verify token signature using provider's public keys
- Check token expiration and timing
- Ensure audience claim matches your client ID

**UserInfo endpoint error:**
- Verify `OIDC_USERINFO_URL` is correct and accessible
- Check that access token has sufficient scopes for UserInfo
- Ensure proper Authorization header format

### Testing Discovery Document

Test your provider's discovery document:

```bash
curl -s https://auth.yourcompany.com/.well-known/openid-configuration | jq '.'
```

This should return JSON with endpoint URLs and supported features.

### Testing Endpoints

Test individual endpoints:

```bash
# Test authorization endpoint (should return HTML login page)
curl -I https://auth.yourcompany.com/auth

# Test token endpoint (should return method not allowed or invalid request)
curl -I https://auth.yourcompany.com/token

# Test UserInfo endpoint (should return unauthorized without token)
curl -I https://auth.yourcompany.com/userinfo
```

## Best Practices

1. **Use Discovery Document** when possible for automatic configuration
2. **Validate ID Tokens** cryptographically for security
3. **Implement proper error handling** for all OIDC errors
4. **Monitor token expiration** and implement refresh logic
5. **Use HTTPS** for all endpoints in production
6. **Store secrets securely** and rotate regularly
7. **Log authentication events** for security monitoring
8. **Implement timeout handling** for provider requests

## Security Considerations

### Token Security
- ID tokens contain user information and should be validated
- Access tokens should be treated as opaque and not parsed
- Refresh tokens provide long-term access and should be stored securely

### Network Security
- All communication should use HTTPS
- Validate SSL certificates in production
- Consider certificate pinning for enhanced security

### Session Security
- Implement proper session management
- Clear session data after logout
- Use secure session storage mechanisms

## Performance Considerations

### Caching
- Cache provider public keys for token validation
- Cache discovery document with appropriate TTL
- Implement connection pooling for provider requests

### Monitoring
- Monitor authentication response times
- Track authentication success/failure rates
- Alert on provider availability issues

## Migration Notes

When migrating to OIDC from other authentication methods:

1. **User Mapping:**
   - Ensure OIDC subject identifiers can be mapped to existing users
   - Plan for changes in user identifiers

2. **Claims Migration:**
   - Map existing user attributes to OIDC claims
   - Handle missing or renamed claims gracefully

3. **Testing:**
   - Test with subset of users first
   - Verify all required claims are available
   - Confirm token validation works correctly