# Apple SSO Configuration

Configure Apple ID authentication for your Devana.ai whitemark instance.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `APPLE_CLIENT_ID` | Your Apple Service ID | Yes | `com.yourcompany.devana` |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID | Yes | `ABC123DEF4` |
| `APPLE_KEY_ID` | Apple private key identifier | Yes | `XYZ987ABC1` |
| `APPLE_CALLBACK_URL` | Callback URL for authentication | Yes | `https://your-domain.com/auth/apple/callback` |

## Setup Instructions

### 1. Apple Developer Account Setup

1. **Create an App ID:**
   - Go to [Apple Developer Console](https://developer.apple.com/account/)
   - Navigate to "Certificates, IDs & Profiles"
   - Create a new App ID with "Sign In with Apple" capability enabled

2. **Create a Service ID:**
   - Create a new Service ID (this will be your `APPLE_CLIENT_ID`)
   - Enable "Sign In with Apple" for this Service ID
   - Configure the callback URL (must match `APPLE_CALLBACK_URL`)

3. **Generate a Private Key:**
   - Create a new key with "Sign In with Apple" enabled
   - Download the private key file (.p8)
   - Note the Key ID (`APPLE_KEY_ID`)

### 2. Environment Configuration

Add the following variables to your environment configuration:

```env
# Apple OAuth Configuration
APPLE_CLIENT_ID=com.yourcompany.devana
APPLE_TEAM_ID=ABC123DEF4
APPLE_KEY_ID=XYZ987ABC1
APPLE_CALLBACK_URL=https://your-domain.com/auth/apple/callback
```

### 3. Private Key Setup

The Apple private key (.p8 file) needs to be accessible to your application. You can either:

**Option A: Environment Variable**
Convert the private key to base64 and store it as an environment variable:
```bash
base64 -i AuthKey_XYZ987ABC1.p8 | tr -d '\n'
```

**Option B: File System**
Place the private key file in a secure location accessible by your application and reference it in your configuration.

### 4. Whitemark Configuration

Configure your whitemark to include Apple as an allowed provider:

```json
{
  "allowedProviders": ["APPLE"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User clicks "Sign in with Apple" button
2. User is redirected to Apple's authentication page
3. User authenticates with their Apple ID
4. Apple redirects back to your callback URL with authorization code
5. Application exchanges code for user information
6. User is created/updated in Devana.ai and logged in

## User Data Mapping

Apple provides limited user information:

| Apple Field | Devana.ai Field | Notes |
|-------------|-----------------|-------|
| `email` | `email` | Primary identifier |
| `name.firstName` | `firstName` | May be empty on subsequent logins |
| `name.lastName` | `lastName` | May be empty on subsequent logins |
| `user` | `providerId` | Unique Apple user identifier |

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains

## Troubleshooting

### Common Issues

**Invalid client_id:**
- Verify `APPLE_CLIENT_ID` matches your Service ID exactly
- Ensure the Service ID has "Sign In with Apple" enabled

**Invalid redirect_uri:**
- Callback URL must match exactly what's configured in Apple Developer Console
- URLs are case-sensitive and must include protocol (https://)

**Invalid key:**
- Verify `APPLE_KEY_ID` matches your private key
- Ensure `APPLE_TEAM_ID` is correct
- Check that the private key file is accessible and valid

**No email in profile:**
- Apple may not provide email on subsequent logins
- Consider prompting users to verify their email address

### Testing

1. Enable Apple SSO in your whitemark configuration
2. Navigate to your login page
3. Click "Sign in with Apple"
4. Complete authentication with a test Apple ID
5. Verify user is created and logged in successfully

## Notes

- **Important** : L'authentification Apple nécessite une validation complète en environnement de production. Veuillez effectuer des tests exhaustifs avant tout déploiement client.
- Apple users may see different privacy options that can affect data availability
- First-time logins typically provide more user information than subsequent logins