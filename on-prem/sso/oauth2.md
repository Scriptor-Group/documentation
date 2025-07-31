# OAuth2 SSO Configuration

Configure generic OAuth 2.0 authentication for your Devana.ai whitemark instance. This provider allows integration with any OAuth 2.0 compliant identity provider that isn't covered by the specialized providers.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `OAUTH2_CLIENT_ID` | OAuth 2.0 Client ID | Yes | `your-client-id` |
| `OAUTH2_CLIENT_SECRET` | OAuth 2.0 Client Secret | Yes | `your-client-secret` |
| `OAUTH2_CALLBACK_URL` | Callback URL for authentication | Yes | `https://your-domain.com/auth/oauth2/callback` |
| `OAUTH2_AUTHORIZATION_URL` | Authorization endpoint URL | Yes | `https://provider.com/oauth/authorize` |
| `OAUTH2_TOKEN_URL` | Token endpoint URL | Yes | `https://provider.com/oauth/token` |

## Setup Instructions

### 1. OAuth Provider Setup

The setup process varies by provider, but generally involves:

1. **Register Application:**
   - Create a new OAuth 2.0 application in your provider's console
   - Configure redirect URI: `https://your-domain.com/auth/oauth2/callback`
   - Note the Client ID and Client Secret

2. **Configure Scopes:**
   - Request appropriate scopes for user information
   - Common scopes: `openid`, `profile`, `email`, `offline_access`

3. **Get Endpoint URLs:**
   - Authorization URL: Where users are redirected for login
   - Token URL: Where authorization codes are exchanged for tokens
   - UserInfo URL: Where user profile information is fetched (if not in token)

### 2. Environment Configuration

Add the following variables to your environment configuration:

```env
# Generic OAuth2 Configuration
OAUTH2_CLIENT_ID=your-client-id
OAUTH2_CLIENT_SECRET=your-client-secret
OAUTH2_CALLBACK_URL=https://your-domain.com/auth/oauth2/callback
OAUTH2_AUTHORIZATION_URL=https://provider.com/oauth/authorize
OAUTH2_TOKEN_URL=https://provider.com/oauth/token
```

### 3. Whitemark Configuration

Configure your whitemark to include OAuth 2.0 as an allowed provider:

```json
{
  "allowedProviders": ["OAUTH2"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User clicks "Sign in with OAuth2" button
2. User is redirected to the authorization URL
3. User authenticates with the OAuth provider
4. Provider redirects back to your callback URL with authorization code
5. Application exchanges code for access token and refresh token
6. Application fetches user profile information
7. User is created/updated in Devana.ai and logged in

## User Data Mapping

The OAuth 2.0 provider should return user information in the token or via a UserInfo endpoint:

| OAuth2 Field | Devana.ai Field | Notes |
|--------------|-----------------|-------|
| `email` | `email` | Primary identifier |
| `given_name` | `firstName` | First name |
| `family_name` | `lastName` | Last name |
| `name` | `displayName` | Full name |
| `sub` or `id` | `providerId` | Unique user identifier |

## Scopes and Permissions

The application requests the following default scopes:

- **`openid`**: Required for OpenID Connect compliance
- **`profile`**: Access to profile information (name, picture, etc.)
- **`email`**: Access to email address
- **`offline_access`**: Refresh token for long-term access

## Provider-Specific Examples

### Keycloak Configuration
```env
OAUTH2_CLIENT_ID=devana-client
OAUTH2_CLIENT_SECRET=your-keycloak-secret
OAUTH2_CALLBACK_URL=https://your-domain.com/auth/oauth2/callback
OAUTH2_AUTHORIZATION_URL=https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/auth
OAUTH2_TOKEN_URL=https://keycloak.yourcompany.com/auth/realms/master/protocol/openid-connect/token
```

### Okta Configuration
```env
OAUTH2_CLIENT_ID=your-okta-client-id
OAUTH2_CLIENT_SECRET=your-okta-secret
OAUTH2_CALLBACK_URL=https://your-domain.com/auth/oauth2/callback
OAUTH2_AUTHORIZATION_URL=https://dev-123456.okta.com/oauth2/default/v1/authorize
OAUTH2_TOKEN_URL=https://dev-123456.okta.com/oauth2/default/v1/token
```

### Auth0 Configuration
```env
OAUTH2_CLIENT_ID=your-auth0-client-id
OAUTH2_CLIENT_SECRET=your-auth0-secret
OAUTH2_CALLBACK_URL=https://your-domain.com/auth/oauth2/callback
OAUTH2_AUTHORIZATION_URL=https://yourcompany.auth0.com/authorize
OAUTH2_TOKEN_URL=https://yourcompany.auth0.com/oauth/token
```

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains
- **Token Security**: Uses authorization code flow with client secret

## Advanced Configuration

### Custom User Profile Handling

If your OAuth provider doesn't follow standard conventions, you may need to customize user profile handling:

1. **Custom UserInfo Endpoint:**
   - Some providers require additional configuration for user profile fetching
   - May need custom headers or parameters

2. **Non-standard Claims:**
   - Provider may use different field names for user information
   - Custom mapping may be required in the authentication callback

### Additional Parameters

Some providers require additional parameters in the authorization request:

```javascript
// Example: Adding audience parameter for Auth0
authorizationURL: 'https://yourcompany.auth0.com/authorize?audience=your-api-identifier'
```

### Token Validation

For enhanced security, consider implementing token validation:

1. **JWT Token Validation:**
   - Verify token signature if using JWT
   - Check token expiration and issuer

2. **Introspection Endpoint:**
   - Some providers offer token introspection
   - Validate token status with provider

## Troubleshooting

### Common Issues

**Invalid client:**
- Verify `OAUTH2_CLIENT_ID` and `OAUTH2_CLIENT_SECRET` are correct
- Ensure client is properly registered with the provider

**Redirect URI mismatch:**
- Ensure `OAUTH2_CALLBACK_URL` exactly matches registered redirect URI
- URLs are case-sensitive and must include protocol (https://)

**Invalid authorization code:**
- Code may have expired (typically 10-minute lifetime)
- Ensure clock synchronization between servers
- Check for duplicate code usage

**Token endpoint error:**
- Verify `OAUTH2_TOKEN_URL` is correct and accessible
- Check that client credentials are being sent correctly
- Ensure proper Content-Type headers

**User profile not available:**
- Provider may not include user info in token response
- May need to implement UserInfo endpoint call
- Check that appropriate scopes were granted

### Testing

1. Enable OAuth2 SSO in your whitemark configuration
2. Navigate to your login page
3. Click "Sign in with OAuth2"
4. Complete authentication with provider account
5. Verify user is created and logged in successfully

### Debug Information

Enable debug logging to see:
- OAuth flow progression
- Token exchange details
- User profile data received
- Any provider-specific errors

## Provider Integration Examples

### Implementing UserInfo Endpoint

If your provider requires a separate UserInfo call:

```javascript
// Custom userProfile implementation would be needed
// This is not currently implemented in the generic OAuth2 provider
```

### Custom Scope Handling

For providers with non-standard scopes:

```javascript
// Modify scope array in provider configuration
scope: ["custom_profile", "custom_email", "custom_openid"]
```

## Best Practices

1. **Use HTTPS** for all endpoints in production
2. **Validate redirect URIs** strictly
3. **Implement proper error handling** for all OAuth errors
4. **Monitor token usage** and implement refresh logic
5. **Log authentication events** for security monitoring
6. **Use state parameter** for CSRF protection (automatically handled)
7. **Implement timeout handling** for provider requests
8. **Store secrets securely** and rotate regularly

## Limitations

The current generic OAuth2 implementation:

- Uses passport-oauth2 strategy
- Assumes standard OAuth 2.0 flow
- May require customization for non-standard providers
- Does not implement UserInfo endpoint calls by default

## Migration from Specific Providers

If migrating from a specific provider (e.g., Google, GitHub) to generic OAuth2:

1. **Verify compatibility** with OAuth 2.0 standard
2. **Test user data mapping** thoroughly
3. **Update configuration** with new endpoints
4. **Plan for user account linking** if changing provider IDs

## When to Use Generic OAuth2

Use the generic OAuth2 provider when:

- Your identity provider isn't covered by specific providers
- You need custom OAuth 2.0 implementation
- Provider follows standard OAuth 2.0 flows
- You want flexibility in configuration

Consider specific providers when:
- Provider has dedicated support (Google, GitHub, etc.)
- Provider-specific features are needed
- Better error handling is required
- Provider has non-standard implementations