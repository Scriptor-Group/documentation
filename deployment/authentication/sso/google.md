# Google SSO Configuration

Configure Google OAuth 2.0 authentication for your Devana.ai whitemark instance.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `GOOGLE_CLIENT_ID` | Google OAuth 2.0 Client ID | Yes | `123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | Google OAuth 2.0 Client Secret | Yes | `your-client-secret` |
| `GOOGLE_CALLBACK_URL` | Callback URL for authentication | Yes | `https://your-domain.com/auth/google/callback` |

## Setup Instructions

### 1. Google Cloud Console Setup

1. **Create/Select Project:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the Google+ API (or newer People API)

2. **Configure OAuth Consent Screen:**
   - Navigate to "APIs & Services" -> "OAuth consent screen"
   - Choose "External" for public applications or "Internal" for G Suite organizations
   - Fill in required information:
     - **App name**: `Devana.ai`
     - **User support email**: Your support email
     - **Developer contact information**: Your email
   - Add scopes: `userinfo.email`, `userinfo.profile`
   - Add test users if in testing mode

3. **Create OAuth 2.0 Credentials:**
   - Go to "APIs & Services" -> "Credentials"
   - Click "Create Credentials" -> "OAuth client ID"
   - Select "Web application" as application type
   - Configure:
     - **Name**: `Devana.ai SSO`
     - **Authorized redirect URIs**: Add `https://your-domain.com/auth/google/callback`
   - Note the **Client ID** and **Client Secret**

### 2. Environment Configuration

Add the following variables to your environment configuration:

```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID=123456789012-abcdefghijklmnopqrstuvwxyz123456.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_CALLBACK_URL=https://your-domain.com/auth/google/callback
```

### 3. Whitemark Configuration

Configure your whitemark to include Google as an allowed provider:

```json
{
  "allowedProviders": ["GOOGLE"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User clicks "Sign in with Google" button
2. User is redirected to Google's authorization page
3. User authenticates with their Google account
4. Google redirects back to your callback URL with authorization code
5. Application exchanges code for access token
6. Application fetches user profile from Google's userinfo endpoint
7. User is created/updated in Devana.ai and logged in

## User Data Mapping

Google provides comprehensive user information through OAuth 2.0:

| Google Field | Devana.ai Field | Notes |
|--------------|-----------------|-------|
| `email` | `email` | Primary identifier (verified) |
| `given_name` | `firstName` | First name |
| `family_name` | `lastName` | Last name |
| `name` | `displayName` | Full name |
| `id` | `providerId` | Unique Google user identifier |
| `picture` | - | Profile picture URL (available but not mapped) |
| `verified_email` | - | Email verification status |

## Scopes and Permissions

The application requests the following scopes:

- **`https://www.googleapis.com/auth/userinfo.profile`**: Access to user's profile information
- **`https://www.googleapis.com/auth/userinfo.email`**: Access to user's email address

These scopes provide:
- Basic profile information (name, picture, locale)
- Email address (verified status)
- Unique user identifier

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains
- **Email Verification**: Google provides verified email addresses
- **Secure Token Exchange**: Uses authorization code flow with client secret

## Google Workspace Integration

### Domain-Restricted Access

For Google Workspace organizations, you can restrict access to users from specific domains:

1. **In Google Cloud Console:**
   - Go to OAuth consent screen configuration
   - Add your organization's domain to authorized domains

2. **Programmatic Verification:**
   - The application can verify user domains in the authentication callback
   - Implement additional checks in the `createUserAccount` function

### Admin Console Configuration

Google Workspace admins can control third-party app access:

1. **Allow/Block Apps:**
   - Go to Google Admin Console
   - Navigate to "Security" -> "API controls"
   - Manage third-party app access

2. **App Verification:**
   - Submit your app for Google verification if needed
   - Unverified apps show warning screens to users

## Advanced Configuration

### Custom Scopes

You may request additional scopes depending on your needs:

```javascript
// Additional available scopes
'https://www.googleapis.com/auth/user.addresses.read'    // Address information
'https://www.googleapis.com/auth/user.birthday.read'     // Birthday information  
'https://www.googleapis.com/auth/user.phonenumbers.read' // Phone numbers
```

### Refresh Tokens

For long-term access, request offline access:

```javascript
// Add to strategy configuration
accessType: 'offline',
approvalPrompt: 'force'
```

## Troubleshooting

### Common Issues

**redirect_uri_mismatch:**
- Ensure `GOOGLE_CALLBACK_URL` exactly matches the authorized redirect URI
- URLs are case-sensitive and must include protocol (https://)
- Path must match exactly (including trailing slashes)

**invalid_client:**
- Verify `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are correct
- Ensure the OAuth client is enabled in Google Cloud Console

**access_denied:**
- User denied permission during OAuth flow
- Check that OAuth consent screen is properly configured
- Verify app isn't in testing mode with restricted users

**App not verified warning:**
- Submit app for Google verification process
- Add authorized domains to OAuth consent screen
- Ensure privacy policy and terms of service URLs are provided

**Invalid request (400):**
- Check that required APIs are enabled (Google+ API or People API)
- Verify OAuth consent screen is published, not in draft mode

### Testing

1. Enable Google SSO in your whitemark configuration
2. Navigate to your login page
3. Click "Sign in with Google"
4. Complete authentication with a Google account
5. Verify user is created and logged in successfully

### Debug Information

Enable detailed logging to see:
- OAuth flow progression
- User profile data received from Google
- Token exchange details
- Any API errors

## Best Practices

- Use HTTPS for redirect URLs in production
- Keep client secrets secure and rotate regularly
- Monitor quota usage in Google Cloud Console
- Submit app for verification to remove warning screens
- Configure proper OAuth consent screen information
- Use domain restrictions for organizational deployments
- Implement proper error handling for quota exceeded scenarios

## Google Identity Services Migration

Google is migrating from Google Sign-In JavaScript platform to Google Identity Services:

**Current Implementation:**
- Uses OAuth 2.0 server-side flow
- Compatible with both old and new Google Identity Services

**Future Considerations:**
- Monitor Google's deprecation timeline for older APIs
- Consider migrating to newer Google Identity libraries when needed
- Test regularly as Google updates their authentication services

## Rate Limits and Quotas

Google APIs have usage limits:

- **Requests per day**: Usually sufficient for authentication use cases
- **Requests per 100 seconds per user**: 100 requests
- **Requests per 100 seconds**: 10,000 requests

Monitor usage in Google Cloud Console under "APIs & Services" -> "Quotas".