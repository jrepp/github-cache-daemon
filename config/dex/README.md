# Dex OIDC Provider Configuration

This directory contains the configuration for the Dex OIDC provider used by Goblet for authentication.

## Overview

Dex is a federated OpenID Connect (OIDC) provider that allows Goblet to authenticate users and validate tokens without relying on Google Cloud Platform credentials.

## Configuration

The `config.yaml` file defines:

### Static Users (for development/testing)

- **admin@goblet.local** - Administrator account
- **developer@goblet.local** - Developer account
- **test@goblet.local** - Test account

All default passwords are: `admin` (change in production!)

### OAuth2 Clients

- **goblet-server** - The main Goblet server
  - Client ID: `goblet-server`
  - Secret: `goblet-secret-key-change-in-production`

- **goblet-cli** - CLI tools and scripts
  - Client ID: `goblet-cli`
  - Secret: `goblet-cli-secret`

- **test-client** - Integration testing
  - Client ID: `test-client`
  - Secret: `test-secret`

## Getting Tokens

### Using the Token Helper CLI

Build and run the token helper:

```bash
# Build the tool
go build -o build/dex-token ./cmd/dex-token

# Get a token
./build/dex-token \
  -dex-url http://localhost:5556/dex \
  -client-id goblet-cli \
  -client-secret goblet-cli-secret \
  -output ./tokens/token.json
```

This will:
1. Open your browser to the Dex login page
2. Start a local callback server on port 5555
3. Save the token to `tokens/token.json`

### Using the Token with Git

Once you have a token:

```bash
# Extract the access token
export AUTH_TOKEN=$(jq -r .access_token ./tokens/token.json)

# Use with git
git -c "http.extraHeader=Authorization: Bearer $AUTH_TOKEN" \
  fetch http://localhost:8888/github.com/your/repo
```

### Manual OAuth2 Flow

1. Navigate to: `http://localhost:5556/dex/auth?client_id=goblet-cli&response_type=code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=openid+profile+email+groups`

2. Log in with one of the static users

3. Copy the authorization code

4. Exchange for a token:

```bash
curl -X POST http://localhost:5556/dex/token \
  -d "grant_type=authorization_code" \
  -d "code=YOUR_CODE_HERE" \
  -d "client_id=goblet-cli" \
  -d "client_secret=goblet-cli-secret" \
  -d "redirect_uri=urn:ietf:wg:oauth:2.0:oob"
```

## Token Export Mount Point

When running in Docker Compose, tokens are exported to the `/tokens` volume which is mounted as `goblet_dev_tokens`. You can:

1. Generate a token inside a container
2. Export it to `/tokens/token.json`
3. Access it from the host or other containers

Example:

```bash
# From within a container
docker exec -it goblet-server-dev /bin/sh
# Generate/copy token to /tokens/token.json
```

## Security Considerations

### Development vs Production

The current configuration is for **DEVELOPMENT ONLY**:

- Uses static passwords (all set to "admin")
- Simple client secrets
- Skips approval screen
- In-memory storage (tokens lost on restart)

### Production Recommendations

For production use:

1. **Change all secrets** in `config.yaml`
2. **Use bcrypt hashes** for passwords (generate with `htpasswd -bnBC 10 "" password | tr -d ':\n'`)
3. **Enable HTTPS** for Dex and Goblet
4. **Use persistent storage** (PostgreSQL, MySQL, etcd, or Kubernetes)
5. **Connect to external IdPs** (Google, GitHub, LDAP, SAML)
6. **Enable approval screen** for production clients
7. **Configure CORS properly** for your domains
8. **Set appropriate token expiry times**
9. **Use Kubernetes secrets** or vault for sensitive data

## Testing

To test the OIDC flow:

```bash
# Start the dev environment
task up

# Wait for services to be healthy
sleep 15

# Get a token
./build/dex-token

# Test with git
export AUTH_TOKEN=$(jq -r .id_token ./tokens/token.json)
git -c "http.extraHeader=Authorization: Bearer $AUTH_TOKEN" \
  ls-remote http://localhost:8888/github.com/google/goblet
```

## Troubleshooting

### Dex not starting

Check logs:
```bash
docker logs goblet-dex-dev
```

Common issues:
- Config file syntax errors
- Port 5556 already in use
- Missing or invalid client secrets

### Token verification fails

- Ensure the token hasn't expired
- Check that `oidc_issuer` matches Dex's issuer URL
- Verify `oidc_client_id` matches the client in Dex config
- Check Goblet server logs for specific errors

### Browser callback fails

- Ensure port 5555 is not in use
- Check that the redirect URI matches the client configuration
- Try using `http://localhost:5555/callback` instead of default

## Additional Resources

- [Dex Documentation](https://dexidp.io/docs/)
- [OIDC Specification](https://openid.net/specs/openid-connect-core-1_0.html)
- [OAuth2 RFC](https://tools.ietf.org/html/rfc6749)
