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
- May have `src/scanner.c` or `src/scanner.cc` (custom scanner, C or C++)
- Should have `queries/highlights.scm` (some grammars like HCL and Kotlin lack these)
- Must have permissive license (MIT, Apache-2.0, BSD, CC0)
- AGPL, GPL, and other copyleft licenses are NOT acceptable

## Grammar Variations

Not all grammars follow the same structure. Common variations:

### Monorepo Grammars
Some repos contain multiple parsers. Use the `subpath` field:
```json
{
  "name": "typescript",
  "subpath": "typescript",  // Parser is in typescript/ subdirectory
  ...
}
```
Examples: TypeScript/TSX, PHP, OCaml, XML, Markdown

### Query Directory Locations
Queries can be in different places depending on repo structure:
- **Standard**: `queries/highlights.scm` at repo root
- **In subpath**: `<subpath>/queries/highlights.scm` (Markdown)
- **At root for monorepos**: `queries/` at root even when using subpath (TypeScript, PHP)
- **Grammar-named subdirectory**: `queries/<grammar>/highlights.scm` (XML has `queries/xml/`)

The build script checks all these locations automatically.

### Non-standard Tag Names
Most repos use `v1.0.0` format, but some don't:
- WhatsApp/tree-sitter-erlang uses `0.1.0` (no `v` prefix)
- alex-pinkus/tree-sitter-swift uses `0.7.1-with-generated-files` (needs generated parser.c)

Always verify the actual tag format on GitHub before adding a grammar.

### Grammars Requiring Generation
Some repos don't include `parser.c` - it must be generated from `grammar.js` using `tree-sitter generate`. Two approaches:

**Option 1: Use tags with pre-generated files**
- alex-pinkus/tree-sitter-swift provides `-with-generated-files` tags

**Option 2: Use `requiresGeneration` flag**
For grammars without pre-generated releases, add the flag to grammars.json:
```json
{
  "name": "perl",
  "org": "tree-sitter-perl",
  "repo": "tree-sitter-perl",
  "version": "ad74e6db234c",  // Commit SHA (no releases)
  "license": "MIT",
  "aliases": ["pl", "pm"],
  "requiresGeneration": true
}
```

When `requiresGeneration: true`:
1. Build script runs `npm install` to get tree-sitter-cli
2. Runs `npx tree-sitter generate` to create `src/parser.c`
3. Then proceeds with normal compilation

**Requirements for generation:**
- Node.js 20+ (CI has this pre-installed)
- Grammar must have `grammar.js` at root (or in subpath)
- Grammar's package.json must list `tree-sitter-cli` as dependency

**When to use commit SHA vs tag:**
- Use commit SHA when repo has no releases (e.g., tree-sitter-perl)
- Use tag when available, preferring `-with-generated-files` variants

### Missing Highlight Queries
Some grammars don't have highlight queries:
- HCL (tree-sitter-grammars/tree-sitter-hcl)
- Kotlin (tree-sitter-grammars/tree-sitter-kotlin)

These grammars will build successfully but won't provide syntax highlighting until queries are added upstream or we provide our own.

## CI/CD

- **PR**: Build and validate, upload artifacts (no release)
- **Push to main**: Build, create release only for `feat:` and `fix:` commits
- **Tag push**: Build and create release with tag version
- **workflow_dispatch**: Build and upload artifacts for testing
- **Runner**: `macos-14` (Apple Silicon, can build universal)
- **Output**: GitHub release with `<grammar>.tar.gz` files and `manifest.json`

## Versioning

Release versions follow the pattern: `v{MAJOR}.{MINOR}.{PATCH}`

- **version.txt**: Contains `MAJOR.MINOR` (e.g., `1.0`)
- **Full version**: `v${version.txt}.${GITHUB_RUN_NUMBER}` (e.g., `v1.0.42`)
- **Individual grammars**: Versions tracked in `grammars.json`

### When to Update version.txt

| Change Type | Action | Example |
|-------------|--------|---------|
| New grammar | Bump MINOR | `feat: add rust grammar` → `1.0` → `1.1` |
| Bug fix | No change | `fix: correct python queries` → `v1.1.44` |
| Breaking change | Bump MAJOR | `1.1` → `2.0` |

The PATCH version auto-increments via `GITHUB_RUN_NUMBER`. Update `version.txt` manually when adding new grammars (bump MINOR) or making breaking changes (bump MAJOR).

## Commit Convention

Use conventional commits:
- `feat:` - New grammars or features (triggers release)
- `fix:` - Bug fixes (triggers release)
- `chore:` - Maintenance tasks (no release)
- `docs:` - Documentation only (no release)
- `ci:` - CI/CD changes (no release)

**Note:** Do not include AI attribution (e.g., "Co-Authored-By: Claude" or "Generated with Claude") in commits or PR descriptions for this repository.
