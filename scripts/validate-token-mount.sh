#!/bin/bash
# Validate that the token is accessible on the mount and can be used

set -e

echo "======================================"
echo "Token Mount Validation"
echo "======================================"
echo ""

# Check if services are running
echo "1. Checking services..."
if ! docker ps | grep -q goblet-token-generator-dev; then
    echo "   ✗ Token generator is not running"
    exit 1
fi
echo "   ✓ Token generator is running"

if ! docker ps | grep -q goblet-server-dev; then
    echo "   ✗ Goblet server is not running"
    exit 1
fi
echo "   ✓ Goblet server is running"

if ! docker ps | grep -q goblet-dex-dev; then
    echo "   ✗ Dex is not running"
    exit 1
fi
echo "   ✓ Dex is running"
echo ""

# Check token exists in volume
echo "2. Validating token exists on mount..."
if docker run --rm -v github-cache-daemon_goblet_dev_tokens:/tokens alpine test -f /tokens/token.json; then
    echo "   ✓ Token file exists"
else
    echo "   ✗ Token file does not exist"
    exit 1
fi
echo ""

# Read and display token
echo "3. Reading token from mount..."
TOKEN_JSON=$(docker run --rm -v github-cache-daemon_goblet_dev_tokens:/tokens alpine cat /tokens/token.json)
echo "   ✓ Token read successfully"
echo ""

# Parse token details
ACCESS_TOKEN=$(echo "$TOKEN_JSON" | jq -r .access_token)
TOKEN_TYPE=$(echo "$TOKEN_JSON" | jq -r .token_type)
CREATED_AT=$(echo "$TOKEN_JSON" | jq -r .created_at)
USER_EMAIL=$(echo "$TOKEN_JSON" | jq -r .user.email)

echo "Token Details:"
echo "  Type: $TOKEN_TYPE"
echo "  User: $USER_EMAIL"
echo "  Created: $CREATED_AT"
echo "  Token: ${ACCESS_TOKEN:0:30}..."
echo ""

# Verify token is accessible from goblet container
echo "4. Validating token accessibility from Goblet container..."
GOBLET_TOKEN=$(docker exec goblet-server-dev cat /tokens/token.json | jq -r .access_token)
if [ "$GOBLET_TOKEN" = "$ACCESS_TOKEN" ]; then
    echo "   ✓ Token matches in goblet container"
else
    echo "   ✗ Token mismatch in goblet container"
    exit 1
fi
echo ""

# Test token with a request
echo "5. Testing token with Goblet server..."
# Test health endpoint (should work without auth)
if curl -sf http://localhost:8890/healthz > /dev/null 2>&1; then
    echo "   ✓ Goblet server is responsive"
else
    echo "   ✗ Goblet server is not responsive"
    exit 1
fi
echo ""

# Show usage instructions
echo "======================================"
echo "✓ All Validations Passed!"
echo "======================================"
echo ""
echo "The bearer token is successfully exported and accessible!"
echo ""
echo "To use the token:"
echo ""
echo "  # Get the token"
echo "  export AUTH_TOKEN=\$(./scripts/get-token.sh access_token)"
echo ""
echo "  # Or use the helper:"
echo "  eval \$(./scripts/get-token.sh env)"
echo ""
echo "  # Use with git"
echo "  git -c \"http.extraHeader=Authorization: Bearer \$AUTH_TOKEN\" \\"
echo "    ls-remote http://localhost:8890/<repo-url>"
echo ""
echo "  # Or test with curl"
echo "  curl -H \"Authorization: Bearer \$AUTH_TOKEN\" \\"
echo "    http://localhost:8890/some/git/endpoint"
echo ""

# Show full token JSON for reference
echo "Full token JSON:"
echo "$TOKEN_JSON" | jq '.'
echo ""
