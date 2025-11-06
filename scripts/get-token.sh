#!/bin/bash
# Helper script to retrieve the exported token from the Docker volume

set -e

VOLUME_NAME="${VOLUME_NAME:-github-cache-daemon_goblet_dev_tokens}"
FORMAT="${1:-json}"

case "$FORMAT" in
    json)
        docker run --rm -v "$VOLUME_NAME:/tokens" alpine cat /tokens/token.json
        ;;
    access_token|token)
        docker run --rm -v "$VOLUME_NAME:/tokens" alpine cat /tokens/token.json | jq -r .access_token
        ;;
    id_token)
        docker run --rm -v "$VOLUME_NAME:/tokens" alpine cat /tokens/token.json | jq -r .id_token
        ;;
    env)
        echo "export AUTH_TOKEN=$(docker run --rm -v "$VOLUME_NAME:/tokens" alpine cat /tokens/token.json | jq -r .access_token)"
        ;;
    *)
        echo "Usage: $0 [json|access_token|id_token|env]"
        echo ""
        echo "Formats:"
        echo "  json         - Full JSON token response (default)"
        echo "  access_token - Just the access token value"
        echo "  id_token     - Just the ID token value"
        echo "  env          - Export command for shell"
        echo ""
        echo "Examples:"
        echo "  $0                    # Show full JSON"
        echo "  $0 access_token       # Show just the token"
        echo "  eval \$($0 env)        # Set AUTH_TOKEN env var"
        exit 1
        ;;
esac
