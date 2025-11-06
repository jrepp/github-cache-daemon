#!/bin/sh
# Docker-compatible token generation script
# This runs inside a container and exports a token to the /tokens volume

set -e

DEX_URL="${DEX_URL:-http://dex:5556/dex}"
TOKEN_FILE="/tokens/token.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "==> Token Generator Service"
echo "    Dex URL: $DEX_URL"
echo "    Output: $TOKEN_FILE"
echo ""

# Wait for Dex to be available
echo "Waiting for Dex to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if wget -q --spider "$DEX_URL/healthz" 2>/dev/null; then
        echo "✓ Dex is ready"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "  Waiting... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "✗ Dex failed to become ready"
    exit 1
fi

echo ""
echo "Generating development token..."

# Create a development token
# This is a mock token for testing - dev-token-* prefix is recognized by the server
cat > "$TOKEN_FILE" <<EOF
{
  "access_token": "dev-token-developer@goblet.local",
  "token_type": "Bearer",
  "expires_in": 86400,
  "id_token": "dev-token-developer@goblet.local",
  "refresh_token": "dev-refresh-token",
  "created_at": "$TIMESTAMP",
  "user": {
    "email": "developer@goblet.local",
    "name": "Developer User",
    "sub": "9b0e24e2-7c3f-4b3e-8a4e-3f5c8b2a1d9e"
  }
}
EOF

# Set permissions
chmod 644 "$TOKEN_FILE"

echo ""
echo "✓ Token exported to: $TOKEN_FILE"
echo ""
echo "Token contents:"
cat "$TOKEN_FILE"
echo ""
echo ""
echo "==> Token is ready for use!"
echo ""
echo "To use from host:"
echo "  docker run --rm -v github-cache-daemon_goblet_dev_tokens:/tokens alpine cat /tokens/token.json"
echo ""
echo "To use in git:"
echo "  export AUTH_TOKEN=\$(docker run --rm -v github-cache-daemon_goblet_dev_tokens:/tokens alpine cat /tokens/token.json | jq -r .access_token)"
echo "  git -c \"http.extraHeader=Authorization: Bearer \$AUTH_TOKEN\" ls-remote http://localhost:8890/<repo>"
echo ""

# Keep container running so token stays accessible
echo "Token generator will remain running to keep token accessible..."
echo "Press Ctrl+C to stop (or use 'task down')"
echo ""

# Sleep forever (container will be stopped with docker-compose down)
while true; do
    sleep 3600
done
