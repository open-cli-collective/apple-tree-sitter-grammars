#!/bin/bash
set -e

# Build all grammars defined in grammars.json
#
# Usage: ./build-all.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
GRAMMARS_JSON="${ROOT_DIR}/grammars.json"

if [ ! -f "$GRAMMARS_JSON" ]; then
    echo "Error: grammars.json not found at $GRAMMARS_JSON"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    echo "Install with: brew install jq"
    exit 1
fi

# Get number of grammars
GRAMMAR_COUNT=$(jq '.grammars | length' "$GRAMMARS_JSON")

# Clean and create dist directory
rm -rf "${ROOT_DIR}/dist"
mkdir -p "${ROOT_DIR}/dist"

if [ "$GRAMMAR_COUNT" -eq 0 ]; then
    echo "No grammars defined in grammars.json"
    echo "dist directory created (empty)"
    exit 0
fi

echo "Building $GRAMMAR_COUNT grammars..."
echo ""

# Track success/failure
BUILT=0
FAILED=0

# Iterate over each grammar
for i in $(seq 0 $((GRAMMAR_COUNT - 1))); do
    NAME=$(jq -r ".grammars[$i].name" "$GRAMMARS_JSON")
    ORG=$(jq -r ".grammars[$i].org" "$GRAMMARS_JSON")
    REPO=$(jq -r ".grammars[$i].repo" "$GRAMMARS_JSON")
    VERSION=$(jq -r ".grammars[$i].version" "$GRAMMARS_JSON")
    SUBPATH=$(jq -r ".grammars[$i].subpath // empty" "$GRAMMARS_JSON")

    echo "[$((i + 1))/$GRAMMAR_COUNT] $NAME"

    if "${SCRIPT_DIR}/build-grammar.sh" "$NAME" "$ORG" "$REPO" "$VERSION" "$SUBPATH"; then
        BUILT=$((BUILT + 1))
    else
        echo "  ✗ Failed to build $NAME"
        FAILED=$((FAILED + 1))
    fi

    echo ""
done

echo "================================"
echo "Build complete: $BUILT succeeded, $FAILED failed"

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
