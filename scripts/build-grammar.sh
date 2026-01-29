#!/bin/bash
set -e

# Build a single tree-sitter grammar as a universal macOS dylib
#
# Usage: ./build-grammar.sh <name> <org> <repo> <version> [subpath]
#
# Example: ./build-grammar.sh javascript tree-sitter tree-sitter-javascript v0.25.0
# Example: ./build-grammar.sh typescript tree-sitter tree-sitter-typescript v0.23.2 typescript

GRAMMAR=$1      # e.g., "javascript"
ORG=$2          # e.g., "tree-sitter"
REPO=$3         # e.g., "tree-sitter-javascript"
VERSION=$4      # e.g., "v0.25.0"
SUBPATH=$5      # e.g., "typescript" (optional, for monorepos)

if [ -z "$GRAMMAR" ] || [ -z "$ORG" ] || [ -z "$REPO" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <name> <org> <repo> <version> [subpath]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/../dist"

# Create temp directory for build
WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

echo "Building $GRAMMAR from $ORG/$REPO@$VERSION..."

# Download release tarball (much faster than git clone)
TARBALL_URL="https://github.com/${ORG}/${REPO}/archive/refs/tags/${VERSION}.tar.gz"
echo "  Downloading $TARBALL_URL..."
curl -sL "$TARBALL_URL" | tar -xz -C "$WORKDIR"

# The extracted folder is named <repo>-<version> (without 'v' prefix)
VERSION_STRIPPED="${VERSION#v}"
SRC_DIR="$WORKDIR/${REPO}-${VERSION_STRIPPED}"

# Handle subpath for monorepos (e.g., typescript in tree-sitter-typescript)
if [ -n "$SUBPATH" ]; then
    SRC_DIR="$SRC_DIR/$SUBPATH"
fi

cd "$SRC_DIR"

# Determine source files
SOURCES="src/parser.c"
if [ -f "src/scanner.c" ]; then
    SOURCES="$SOURCES src/scanner.c"
    echo "  Found scanner.c, including in build"
fi

# Check for C++ scanner
if [ -f "src/scanner.cc" ]; then
    SOURCES="$SOURCES src/scanner.cc"
    echo "  Found scanner.cc (C++), including in build"
fi

# Build universal binary (arm64 + x86_64)
mkdir -p "$DIST_DIR/$GRAMMAR"
echo "  Compiling universal binary..."
clang -arch arm64 -arch x86_64 \
    -shared -fPIC -O3 \
    -I src \
    $SOURCES \
    -o "$DIST_DIR/$GRAMMAR/$GRAMMAR.dylib"

# Copy queries
if [ -d "queries" ]; then
    echo "  Copying queries..."
    cp -r queries "$DIST_DIR/$GRAMMAR/"
else
    echo "  Warning: No queries directory found"
fi

# Verify build
echo "  Verifying build..."
file "$DIST_DIR/$GRAMMAR/$GRAMMAR.dylib"

echo "✓ Built $GRAMMAR.dylib (universal) + queries"
