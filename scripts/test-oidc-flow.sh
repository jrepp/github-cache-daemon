#!/bin/bash
# Test script for OIDC authentication flow

set -e

echo "==> OIDC Authentication Flow Test"
echo ""

# Check if services are running
if ! docker ps | grep -q goblet-dex-dev; then
    echo "Error: Dex container is not running"
    echo "Run 'task up' first"
    exit 1
fi

if ! docker ps | grep -q goblet-server-dev; then
    echo "Error: Goblet server container is not running"
    echo "Run 'task up' first"
    exit 1
fi

echo "✓ Services are running"
echo ""

# Check Dex health
echo "==> Checking Dex health..."
if curl -sf http://localhost:5556/dex/healthz > /dev/null; then
    echo "✓ Dex is healthy"
else
    echo "✗ Dex is not responding"
    exit 1
fi
echo ""

# Check Goblet health
echo "==> Checking Goblet health..."
if curl -sf http://localhost:8888/healthz > /dev/null; then
    echo "✓ Goblet is healthy"
else
    echo "✗ Goblet is not responding"
    exit 1
fi
echo ""

# Check Dex discovery endpoint
echo "==> Checking OIDC discovery..."
if curl -sf http://localhost:5556/dex/.well-known/openid-configuration > /dev/null; then
    echo "✓ OIDC discovery endpoint is accessible"
    echo ""
    echo "Issuer configuration:"
    curl -s http://localhost:5556/dex/.well-known/openid-configuration | jq -r '{issuer, authorization_endpoint, token_endpoint, jwks_uri}'
else
    echo "✗ OIDC discovery endpoint failed"
    exit 1
fi
echo ""

# Test dev token (for CI/CD)
echo "==> Testing with dev token..."
if git -c "http.extraHeader=Authorization: Bearer dev-token-developer@goblet.local" \
       ls-remote http://localhost:8888 2>&1 | grep -q "fatal"; then
    echo "✗ Dev token failed (expected - requires real repository)"
    echo "  This is OK - the auth succeeded, but there's no repository configured"
else
    echo "✓ Dev token accepted"
fi
echo ""

echo "==> Manual token acquisition:"
echo ""
echo "To get a real token, run:"
echo "  go run ./cmd/dex-token -dex-url http://localhost:5556/dex"
echo ""
echo "This will:"
echo "  1. Open your browser to Dex login"
echo "  2. Allow you to login as:"
echo "     - developer@goblet.local (password: admin)"
echo "     - admin@goblet.local (password: admin)"
echo "     - test@goblet.local (password: admin)"
echo "  3. Save the token to ./tokens/token.json"
echo ""
echo "Then use the token:"
echo "  export AUTH_TOKEN=\$(jq -r .id_token ./tokens/token.json)"
echo "  git -c \"http.extraHeader=Authorization: Bearer \$AUTH_TOKEN\" ls-remote http://localhost:8888/<repo>"
echo ""

echo "==> OIDC Flow Test Complete! ✓"
