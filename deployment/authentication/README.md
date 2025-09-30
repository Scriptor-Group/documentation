# Authentication SSO

Configuration de l'authentification unique (SSO) pour Devana.ai.

## 🔐 Providers disponibles

### Cloud Providers
- [Azure AD / Microsoft Entra](./azure.md) - Active Directory et Entra ID
- [Google Workspace](./google.md) - Google OAuth
- [Apple](./apple.md) - Sign in with Apple
- [GitHub](./github.md) - GitHub OAuth

### Enterprise
- [LDAP](./ldap.md) - Lightweight Directory Access Protocol
- [OIDC](./oidc.md) - OpenID Connect générique
- [OAuth 2.0](./oauth2.md) - OAuth 2.0 générique

### Solutions tierces
- [Authentik](./authentik.md) - Solution SSO open-source
- [Whitemark](./whitemark.md) - Configuration spécifique Whitemark

## 🚀 Configuration rapide

1. Choisir votre provider SSO
2. Suivre le guide de configuration correspondant
3. Configurer les variables d'environnement
4. Tester la connexion

## 📝 Variables d'environnement communes

```bash
# Activer le SSO
SSO_ENABLED=true

# Provider spécifique (voir la documentation de chaque provider)
SSO_PROVIDER=azure|google|ldap|oidc|...
```

## 🔗 Ressources

- [Variables d'environnement complètes](../configuration/environment-variables.md)
- [Guide de déploiement](../README.md)