#!/bin/bash
# Helper script to get an OIDC token from Dex
# This uses the password grant flow for CLI usage

set -e

DEX_URL="${DEX_URL:-http://localhost:5556/dex}"
CLIENT_ID="${CLIENT_ID:-goblet-cli}"
CLIENT_SECRET="${CLIENT_SECRET:-goblet-cli-secret}"
USERNAME="${USERNAME:-developer@goblet.local}"
PASSWORD="${PASSWORD:-admin}"
TOKEN_FILE="${TOKEN_FILE:-./tokens/token.json}"

echo "Getting token from Dex..."
echo "  Dex URL: $DEX_URL"
echo "  Client ID: $CLIENT_ID"
echo "  Username: $USERNAME"

# Create tokens directory if it doesn't exist
mkdir -p "$(dirname "$TOKEN_FILE")"

# Get token using password grant (requires Dex to support this)
# Note: Dex doesn't support password grant directly, so we'll use device code flow instead
# For now, we'll create a simple token for testing

# Alternative: Use dex-token-helper or implement OAuth2 device flow
# For development, we can use a pre-generated token or implement device flow

echo ""
echo "Note: Dex requires OAuth2 authorization code flow."
echo "For development, you can:"
echo "  1. Use the device code flow"
echo "  2. Navigate to http://localhost:5556/dex/auth and complete OAuth2 flow"
echo "  3. Use the token endpoint with authorization code"
echo ""
echo "For testing, a static token will be generated for CI/CD purposes."

# Generate a JWT-like token for testing (this is a placeholder)
# In production, you'd complete the OAuth2 flow
cat > "$TOKEN_FILE" <<EOF
{
  "access_token": "dev-token-${USERNAME}",
  "token_type": "Bearer",
  "expires_in": 86400,
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjRlNjU5ODQ4YjY5YzExZWM4MWMwMDI0MmFjMTMwMDAzIn0.eyJpc3MiOiJodHRwOi8vZGV4OjU1NTYvZGV4IiwiaWF0IjoxNjE2MDgwNzg1LCJleHAiOjE5MzE0NDA3ODUsImF1ZCI6WyJnb2JsZXQtY2xpIl0sInN1YiI6IjliMGUyNGUyLTdjM2YtNGIzZS04YTRlLTNmNWM4YjJhMWQ5ZSIsImVtYWlsIjoiJHtVU0VSTkFNRX0iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IkRldmVsb3BlciJ9.placeholder",
  "refresh_token": "placeholder-refresh-token"
}
EOF

echo "Token saved to: $TOKEN_FILE"
echo ""
echo "To use this token with git:"
echo "  export AUTH_TOKEN=\$(jq -r .access_token $TOKEN_FILE)"
echo "  git -c \"http.extraHeader=Authorization: Bearer \$AUTH_TOKEN\" fetch <url>"
echo ""
echo "Or export to mounted volume:"
echo "  cp $TOKEN_FILE /tokens/token.json"
