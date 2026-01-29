#!/bin/bash
set -e

# Generate manifest.json from built grammars
#
# Usage: ./generate-manifest.sh
#
# Creates dist/manifest.json with grammar metadata and checksums

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
DIST_DIR="${ROOT_DIR}/dist"
GRAMMARS_JSON="${ROOT_DIR}/grammars.json"
MANIFEST="${DIST_DIR}/manifest.json"

if [ ! -f "$GRAMMARS_JSON" ]; then
    echo "Error: grammars.json not found"
    exit 1
fi

if [ ! -d "$DIST_DIR" ]; then
    echo "Error: dist directory not found. Run build-all.sh first."
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

echo "Generating manifest.json..."

# Start building manifest
echo "{" > "$MANIFEST"
echo '  "version": "1.0.0",' >> "$MANIFEST"
echo '  "generatedAt": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",' >> "$MANIFEST"
echo '  "grammars": {' >> "$MANIFEST"

# Get number of grammars
GRAMMAR_COUNT=$(jq '.grammars | length' "$GRAMMARS_JSON")
CURRENT=0

for i in $(seq 0 $((GRAMMAR_COUNT - 1))); do
    NAME=$(jq -r ".grammars[$i].name" "$GRAMMARS_JSON")
    DISPLAY_NAME=$(jq -r ".grammars[$i].displayName" "$GRAMMARS_JSON")
    VERSION=$(jq -r ".grammars[$i].version" "$GRAMMARS_JSON")
    LICENSE=$(jq -r ".grammars[$i].license" "$GRAMMARS_JSON")
    ALIASES=$(jq -c ".grammars[$i].aliases // []" "$GRAMMARS_JSON")

    DYLIB_PATH="$DIST_DIR/$NAME/$NAME.dylib"

    if [ ! -f "$DYLIB_PATH" ]; then
        echo "  Warning: $NAME.dylib not found, skipping"
        continue
    fi

    # Calculate checksum
    CHECKSUM=$(shasum -a 256 "$DYLIB_PATH" | cut -d' ' -f1)

    # Get file size
    SIZE=$(stat -f%z "$DYLIB_PATH" 2>/dev/null || stat --printf="%s" "$DYLIB_PATH")

    # Add comma if not first
    if [ $CURRENT -gt 0 ]; then
        echo "," >> "$MANIFEST"
    fi

    # Write grammar entry
    cat >> "$MANIFEST" << EOF
    "$NAME": {
      "displayName": "$DISPLAY_NAME",
      "version": "$VERSION",
      "license": "$LICENSE",
      "aliases": $ALIASES,
      "checksum": "$CHECKSUM",
      "size": $SIZE
    }
EOF

    CURRENT=$((CURRENT + 1))
done

# Close JSON
echo "" >> "$MANIFEST"
echo "  }" >> "$MANIFEST"
echo "}" >> "$MANIFEST"

# Validate JSON
if jq empty "$MANIFEST" 2>/dev/null; then
    echo "✓ Generated $MANIFEST with $CURRENT grammars"
else
    echo "Error: Generated manifest is not valid JSON"
    exit 1
fi
