#!/bin/bash
# Generate a test token for development/testing
# This script creates a mock JWT token for testing purposes

set -e

DEX_URL="${DEX_URL:-http://localhost:5557/dex}"
OUTPUT_DIR="${OUTPUT_DIR:-./tokens}"
OUTPUT_FILE="${OUTPUT_FILE:-$OUTPUT_DIR/token.json}"

echo "==> Generating test token for development..."
echo "    Dex URL: $DEX_URL"
echo "    Output: $OUTPUT_FILE"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# For development/testing, create a mock token structure
# In production, this would be obtained via OAuth2 flow
cat > "$OUTPUT_FILE" <<'EOF'
{
  "access_token": "dev-token-developer@goblet.local",
  "token_type": "Bearer",
  "expires_in": 86400,
  "id_token": "dev-token-developer@goblet.local",
  "refresh_token": "dev-refresh-token",
  "created_at": "TIMESTAMP"
}
EOF

# Replace timestamp
sed -i.bak "s/TIMESTAMP/$(date -u +%Y-%m-%dT%H:%M:%SZ)/" "$OUTPUT_FILE" && rm -f "$OUTPUT_FILE.bak"

echo ""
echo "✓ Test token created at: $OUTPUT_FILE"
echo ""
echo "Token details:"
cat "$OUTPUT_FILE" | jq '.'
echo ""
echo "To use this token:"
echo "  export AUTH_TOKEN=\$(jq -r .access_token $OUTPUT_FILE)"
echo "  git -c \"http.extraHeader=Authorization: Bearer \$AUTH_TOKEN\" ls-remote http://localhost:8890/<repo>"
echo ""
echo "Note: This is a development token. The Goblet server with OIDC mode"
echo "      accepts 'dev-token-*' prefixed tokens for testing."
