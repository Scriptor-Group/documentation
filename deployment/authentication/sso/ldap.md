# LDAP SSO Configuration

Configure LDAP (Lightweight Directory Access Protocol) authentication for your Devana.ai whitemark instance. This allows integration with existing directory services like Active Directory, OpenLDAP, or other LDAP-compliant systems.

## Required Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `LDAP_URL` | LDAP server URL | Yes | `ldap://ldap.yourcompany.com:389` or `ldaps://ldap.yourcompany.com:636` |
| `LDAP_BIND_DN` | Distinguished name for binding | Yes | `cn=admin,dc=yourcompany,dc=com` |
| `LDAP_BIND_CREDENTIALS` | Password for bind DN | Yes | `your-admin-password` |
| `LDAP_SEARCH_BASE` | Base DN for user searches | Yes | `ou=users,dc=yourcompany,dc=com` |
| `LDAP_SEARCH_FILTER` | Filter for finding users | Yes | `(uid={{username}})` or `(sAMAccountName={{username}})` |

## Setup Instructions

### 1. LDAP Server Configuration

Ensure your LDAP server is properly configured and accessible:

1. **Network Access:**
   - LDAP server must be accessible from your Devana.ai server
   - Standard ports: 389 (LDAP), 636 (LDAPS)
   - Ensure firewall rules allow connections

2. **Service Account:**
   - Create a service account for binding to LDAP
   - Grant read permissions for user directory
   - Use least-privilege principle

### 2. Environment Configuration

**For Active Directory:**
```env
# LDAP Configuration for Active Directory
LDAP_URL=ldap://dc.yourcompany.com:389
LDAP_BIND_DN=cn=service-account,cn=Users,dc=yourcompany,dc=com
LDAP_BIND_CREDENTIALS=your-service-account-password
LDAP_SEARCH_BASE=cn=Users,dc=yourcompany,dc=com
LDAP_SEARCH_FILTER=(sAMAccountName={{username}})
```

**For OpenLDAP:**
```env
# LDAP Configuration for OpenLDAP
LDAP_URL=ldap://ldap.yourcompany.com:389
LDAP_BIND_DN=cn=admin,dc=yourcompany,dc=com
LDAP_BIND_CREDENTIALS=your-admin-password
LDAP_SEARCH_BASE=ou=people,dc=yourcompany,dc=com
LDAP_SEARCH_FILTER=(uid={{username}})
```

**For Secure LDAP (LDAPS):**
```env
# LDAP Configuration with SSL/TLS
LDAP_URL=ldaps://ldap.yourcompany.com:636
LDAP_BIND_DN=cn=admin,dc=yourcompany,dc=com
LDAP_BIND_CREDENTIALS=your-admin-password
LDAP_SEARCH_BASE=ou=users,dc=yourcompany,dc=com
LDAP_SEARCH_FILTER=(uid={{username}})
```

### 3. Whitemark Configuration

Configure your whitemark to include LDAP as an allowed provider:

```json
{
  "allowedProviders": ["LDAP"],
  "registrationType": ["SSO"]
}
```

## Authentication Flow

1. User enters username and password on login form
2. Application binds to LDAP server using service account credentials
3. Application searches for user using the provided username
4. If user found, application attempts to bind with user's credentials
5. If bind successful, user profile is extracted from LDAP attributes
6. User is created/updated in Devana.ai and logged in

## User Data Mapping

LDAP attributes are mapped to Devana.ai user fields:

| LDAP Attribute | Devana.ai Field | Notes |
|----------------|-----------------|-------|
| `mail` or `userPrincipalName` | `email` | Primary identifier |
| `givenName` | `firstName` | First name |
| `sn` | `lastName` | Last name |
| `cn` | `displayName` | Common name (fallback for names) |
| `uid` | `providerId` | Unique user identifier |
| `dn` | - | Distinguished name (available but not mapped) |

## LDAP Attributes Retrieved

The system retrieves the following attributes from LDAP:

```javascript
searchAttributes: [
  "dn",                    // Distinguished Name
  "uid",                   // User ID
  "cn",                    // Common Name
  "sn",                    // Surname
  "givenName",             // Given Name
  "mail",                  // Email Address
  "userPrincipalName",     // User Principal Name (AD)
]
```

## Search Filter Examples

### Active Directory Filters
```bash
# By username
(sAMAccountName={{username}})

# By email
(userPrincipalName={{username}})

# By multiple attributes
(|(sAMAccountName={{username}})(userPrincipalName={{username}}))
```

### OpenLDAP Filters
```bash
# By user ID
(uid={{username}})

# By email
(mail={{username}})

# By multiple attributes
(|(uid={{username}})(mail={{username}}))
```

## Security Considerations

### Connection Security

1. **Use LDAPS when possible:**
   ```env
   LDAP_URL=ldaps://ldap.yourcompany.com:636
   ```

2. **StartTLS for non-encrypted connections:**
   - LDAP over TLS on standard port 389
   - Requires server support for StartTLS

### Service Account Security

1. **Least Privilege:**
   - Grant only read permissions for user directory
   - Avoid using administrative accounts

2. **Credential Management:**
   - Store credentials securely
   - Rotate service account passwords regularly
   - Monitor service account usage

### Network Security

1. **Firewall Rules:**
   - Restrict LDAP access to authorized servers only
   - Use VPN or private networks when possible

2. **Monitoring:**
   - Log authentication attempts
   - Monitor for suspicious activity

## Advanced Configuration

### Custom Attributes

To retrieve additional LDAP attributes, modify the search attributes:

```javascript
// In ldap.ts provider configuration
searchAttributes: [
  "dn", "uid", "cn", "sn", "givenName", "mail", "userPrincipalName",
  "department",        // Department
  "title",            // Job title
  "telephoneNumber",   // Phone number
  "memberOf"          // Group memberships
]
```

### Group-Based Access Control

LDAP can provide group information for authorization:

1. **Add group attributes to search:**
   ```javascript
   searchAttributes: [..., "memberOf"]
   ```

2. **Implement group checking in authentication callback:**
   ```javascript
   // Check if user is member of required groups
   const requiredGroups = ["cn=devana-users,ou=groups,dc=company,dc=com"];
   const userGroups = Array.isArray(user.memberOf) ? user.memberOf : [user.memberOf];
   ```

## Troubleshooting

### Common Issues

**Connection refused / timeout:**
- Verify LDAP server is running and accessible
- Check firewall rules and network connectivity
- Confirm correct port (389 for LDAP, 636 for LDAPS)

**Bind failed / Invalid credentials:**
- Verify `LDAP_BIND_DN` and `LDAP_BIND_CREDENTIALS` are correct
- Check service account exists and has proper permissions
- Ensure DN format matches your LDAP schema

**User not found:**
- Verify `LDAP_SEARCH_BASE` contains the user accounts
- Check `LDAP_SEARCH_FILTER` matches your LDAP schema
- Confirm username format matches expected attribute

**No email found in profile:**
- User may not have `mail` or `userPrincipalName` attributes
- Check LDAP user attributes with LDAP browser tool
- Verify email attribute is populated in directory

**SSL/TLS certificate errors:**
- For LDAPS, ensure valid SSL certificate on LDAP server
- Consider certificate validation settings for self-signed certificates
- Check certificate chain and CA trust

### Testing LDAP Connection

Use command-line tools to test LDAP connectivity:

```bash
# Test basic connection
ldapsearch -x -H ldap://ldap.yourcompany.com:389 -D "cn=admin,dc=yourcompany,dc=com" -W -b "dc=yourcompany,dc=com" "(objectClass=person)"

# Test user search
ldapsearch -x -H ldap://ldap.yourcompany.com:389 -D "cn=admin,dc=yourcompany,dc=com" -W -b "ou=users,dc=yourcompany,dc=com" "(uid=testuser)"
```

### Debug Logging

Enable LDAP debug logging:

```env
DEBUG=ldap*
```

This will show:
- Connection attempts
- Bind operations
- Search queries and results
- Authentication flow details

## Best Practices

1. **Use LDAPS or StartTLS** for encrypted connections
2. **Create dedicated service account** with minimal permissions
3. **Implement proper error handling** for connection failures
4. **Monitor authentication logs** for security issues
5. **Test failover scenarios** if using multiple LDAP servers
6. **Document your LDAP schema** and attribute mappings
7. **Regularly audit service account permissions**
8. **Consider connection pooling** for high-volume deployments

## High Availability

For production deployments, consider:

1. **Multiple LDAP Servers:**
   - Configure failover to secondary servers
   - Use load balancers for LDAP traffic

2. **Connection Pooling:**
   - Maintain persistent connections
   - Handle connection timeouts gracefully

3. **Monitoring:**
   - Monitor LDAP server health
   - Alert on authentication failures
   - Track response times

## Migration Notes

When migrating from other authentication systems:

1. **User Mapping:**
   - Ensure LDAP users can be matched to existing accounts
   - Plan for email address changes

2. **Testing:**
   - Test with subset of users first
   - Verify all required attributes are available
   - Confirm group memberships work as expected

3. **Rollback Plan:**
   - Keep alternative authentication methods available
   - Document rollback procedures