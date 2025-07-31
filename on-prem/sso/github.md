# GitHub SSO Configuration

Configure GitHub OAuth authentication for your Devana.ai whitemark instance.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `GITHUB_CLIENT_ID` | GitHub OAuth App Client ID | Yes | `Iv1.1234567890abcdef` |
| `GITHUB_CLIENT_SECRET` | GitHub OAuth App Client Secret | Yes | `your-client-secret` |
| `GITHUB_CALLBACK_URL` | Callback URL for authentication | Yes | `https://your-domain.com/auth/github/callback` |

## Setup Instructions

### 1. GitHub OAuth App Setup

1. **Create OAuth App:**
   - Go to [GitHub Developer Settings](https://github.com/settings/developers)
   - Click "OAuth Apps" ’ "New OAuth App"
   - Fill in the application details:
     - **Application name**: `Devana.ai SSO`
     - **Homepage URL**: `https://your-domain.com`
     - **Application description**: Optional description
     - **Authorization callback URL**: `https://your-domain.com/auth/github/callback`

2. **Get Credentials:**
   - After creation, note the **Client ID** (`GITHUB_CLIENT_ID`)
   - Generate a new **Client Secret** (`GITHUB_CLIENT_SECRET`)

### 2. Environment Configuration

Add the following variables to your environment configuration:

```env
# GitHub OAuth Configuration
GITHUB_CLIENT_ID=Iv1.1234567890abcdef
GITHUB_CLIENT_SECRET=your-client-secret
GITHUB_CALLBACK_URL=https://your-domain.com/auth/github/callback
```

### 3. Whitemark Configuration

Configure your whitemark to include GitHub as an allowed provider:

```json
{
  "allowedProviders": ["GITHUB"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User clicks "Sign in with GitHub" button
2. User is redirected to GitHub's authorization page
3. User authenticates with their GitHub credentials
4. GitHub redirects back to your callback URL with authorization code
5. Application exchanges code for access token
6. Application fetches user profile and email from GitHub API
7. User is created/updated in Devana.ai and logged in

## User Data Mapping

GitHub provides comprehensive user information:

| GitHub Field | Devana.ai Field | Notes |
|--------------|-----------------|-------|
| `email` | `email` | Primary identifier from profile or emails API |
| `login` | `firstName` | GitHub username used as first name |
| `name` | `lastName` | Display name used as last name |
| `id` | `providerId` | Unique GitHub user ID |

## Scopes and Permissions

The application requests the following scope:

- **`user:email`**: Access to user's email addresses

This scope provides:
- Read access to user's profile information
- Access to user's email addresses (including private emails)

## User Profile Data Available

GitHub provides extensive profile information:

```typescript
interface GitHubProfile {
  id: string;                    // Unique user ID
  login: string;                 // Username
  name: string;                  // Display name
  email: string;                 // Primary email
  avatar_url: string;            // Profile picture URL
  html_url: string;              // Profile page URL
  company: string;               // Company name
  blog: string;                  // Website/blog URL
  location: string;              // Location
  bio: string;                   // User bio
  public_repos: number;          // Number of public repositories
  followers: number;             // Number of followers
  following: number;             // Number of users following
  created_at: string;            // Account creation date
  updated_at: string;            // Last profile update
}
```

## Security Features

- **CSRF Protection**: State parameter validation prevents cross-site request forgery
- **Session Management**: Secure session handling with automatic cleanup
- **Domain Validation**: Authentication tied to specific whitemark domains
- **Email Verification**: Accesses both public and verified email addresses

## GitHub-Specific Considerations

### Email Privacy

GitHub users can set their email addresses as private. The `user:email` scope ensures access to:
- Primary email address (even if set as private)
- All verified email addresses
- Notification email preferences

### Organization Restrictions

If your GitHub OAuth App is owned by an organization, you may need to:
1. Enable third-party application access in organization settings
2. Configure organization approval workflows
3. Consider using GitHub Apps instead of OAuth Apps for enhanced security

### Rate Limiting

GitHub API has rate limits that may affect authentication:
- OAuth Apps: 5,000 requests per hour per authenticated user
- The authentication flow typically uses minimal API calls

## Troubleshooting

### Common Issues

**Application suspended or blocked:**
- Check GitHub OAuth App status in developer settings
- Verify the app hasn't violated GitHub's terms of service

**Redirect URI mismatch:**
- Ensure `GITHUB_CALLBACK_URL` exactly matches the registered callback URL
- URLs are case-sensitive and must include protocol (https://)

**Invalid client credentials:**
- Verify `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` are correct
- Ensure the client secret hasn't been regenerated

**User email not available:**
- User may have set all email addresses as private
- Verify the `user:email` scope is being requested
- Check that the OAuth app has been granted necessary permissions

**Organization access denied:**
- User's organization may have third-party access restrictions
- Admin approval may be required for organization members

### Testing

1. Enable GitHub SSO in your whitemark configuration
2. Navigate to your login page
3. Click "Sign in with GitHub"
4. Complete authentication with a GitHub account
5. Verify user is created and logged in successfully

### Debug Information

The authentication process logs:
- User profile information received from GitHub
- Email addresses available for the user
- Any API errors or rate limiting issues

## Best Practices

- Use HTTPS for callback URLs in production
- Monitor OAuth app usage in GitHub developer settings
- Regularly review and rotate client secrets
- Consider organization approval workflows for enterprise usage
- Keep track of API rate limits if scaling to many users
- Use GitHub Apps instead of OAuth Apps if you need more granular permissions

## GitHub Apps Alternative

For enhanced security and more granular permissions, consider using GitHub Apps instead of OAuth Apps:

**Benefits of GitHub Apps:**
- Fine-grained permissions
- Higher rate limits
- Better audit logs
- Organization-level installation controls

**Note:** The current implementation uses OAuth Apps (passport-github2 strategy). Migrating to GitHub Apps would require implementation changes.