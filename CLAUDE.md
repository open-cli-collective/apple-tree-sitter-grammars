# CLAUDE.md

This file provides guidance for working with the apple-tree-sitter-grammars project.

## Project Overview

This repository builds and distributes precompiled tree-sitter grammars as universal macOS dynamic libraries for use by SwiftMarkdown.

## Build Commands

```bash
# Build all grammars from grammars.json
./scripts/build-all.sh

# Build a single grammar
./scripts/build-grammar.sh <name> <org> <repo> <version>

# Generate manifest.json
./scripts/generate-manifest.sh

# Example: Build JavaScript grammar
./scripts/build-grammar.sh javascript tree-sitter tree-sitter-javascript v0.25.0
```

## Project Structure

| Directory/File | Description |
|----------------|-------------|
| `scripts/` | Build and manifest generation scripts |
| `grammars.json` | Master list of grammars to build |
| `dist/` | Build output (gitignored) |
| `.github/workflows/` | CI/CD for building and releasing |

## Development Workflow

- Always branch from `main` for new work
- Each PR must close its corresponding issue
- One grammar per commit, multiple commits per PR is fine
- Issue per batch of grammars (sensible groupings)

## Adding a New Grammar

1. Verify the grammar has a permissive license (MIT, Apache-2.0, BSD, CC0)
2. Add entry to `grammars.json`:
   ```json
   {
     "name": "language",
     "displayName": "Language Name",
     "org": "github-org",
     "repo": "tree-sitter-language",
     "version": "v1.0.0",
     "license": "MIT",
     "aliases": ["lang", "alias"]
   }
   ```
3. Run `./scripts/build-grammar.sh` locally to test
4. Verify universal binary: `file dist/language.dylib`
5. Create PR with commit message: `feat: add <language> grammar`

## Grammar Requirements

- Must have `src/parser.c` (generated parser)
- May have `src/scanner.c` (custom scanner)
- Must have `queries/highlights.scm`
- Must have permissive license (MIT, Apache-2.0, BSD, CC0)
- AGPL, GPL, and other copyleft licenses are NOT acceptable

## CI/CD

- **Trigger**: Tag push (`v*`) or manual dispatch
- **Runner**: `macos-14` (Apple Silicon, can build universal)
- **Output**: GitHub release with `<grammar>.tar.gz` files and `manifest.json`

## Versioning

- Base version in release tags (e.g., `v1.0.0`)
- Individual grammar versions tracked in `grammars.json`
- Manifest includes all version info for consumers

## Commit Convention

Use conventional commits:
- `feat:` - New grammars or features
- `fix:` - Bug fixes
- `chore:` - Maintenance tasks
- `docs:` - Documentation only
