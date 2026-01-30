# apple-tree-sitter-grammars

Precompiled tree-sitter grammars as universal macOS dynamic libraries for [SwiftMarkdown](https://github.com/open-cli-collective/SwiftMarkdown).

## Overview

Tree-sitter provides incremental parsing for programming languages, but only distributes source code. This repository builds tree-sitter grammars into universal macOS dylibs (arm64 + x86_64) and distributes them via GitHub releases.

## Usage

SwiftMarkdown downloads grammars on first use from this repository's releases. Users don't need to interact with this repo directly.

### For Developers

Download a grammar tarball from [releases](https://github.com/open-cli-collective/apple-tree-sitter-grammars/releases):

```bash
# Download JavaScript grammar
curl -LO https://github.com/open-cli-collective/apple-tree-sitter-grammars/releases/download/v1.0.0/javascript.tar.gz
tar -xzf javascript.tar.gz

# Contents:
# javascript/
# ├── javascript.dylib  (universal: arm64 + x86_64)
# └── queries/
#     └── highlights.scm
```

Load the grammar in your application:

```c
void* handle = dlopen("javascript.dylib", RTLD_NOW);
TSLanguage* (*tree_sitter_javascript)(void) = dlsym(handle, "tree_sitter_javascript");
TSLanguage* lang = tree_sitter_javascript();
```

## Supported Languages (43)

| Language | Repo | Version | License | Aliases |
|----------|------|---------|---------|---------|
| Bash | tree-sitter/tree-sitter-bash | v0.25.1 | MIT | sh, shell, zsh |
| C | tree-sitter/tree-sitter-c | v0.24.1 | MIT | |
| C# | tree-sitter/tree-sitter-c-sharp | v0.23.1 | MIT | csharp, cs |
| C++ | tree-sitter/tree-sitter-cpp | v0.23.4 | MIT | cc, cxx |
| Clojure | sogaiu/tree-sitter-clojure | v0.0.13 | CC0-1.0 | clj, cljs, cljc, bb |
| Common Lisp | tree-sitter-grammars/tree-sitter-commonlisp | v0.4.1 | MIT | lisp, cl |
| CSS | tree-sitter/tree-sitter-css | v0.25.0 | MIT | |
| Diff | tree-sitter-grammars/tree-sitter-diff | v0.1.0 | MIT | patch |
| Dockerfile | camdencheek/tree-sitter-dockerfile | v0.2.0 | MIT | |
| Elixir | elixir-lang/tree-sitter-elixir | v0.3.4 | Apache-2.0 | ex, exs |
| Erlang | WhatsApp/tree-sitter-erlang | 0.1.0 | Apache-2.0 | erl |
| Fortran | stadelmanma/tree-sitter-fortran | v0.5.1 | MIT | f90, f95, f03 |
| F# | ionide/tree-sitter-fsharp | v0.1.0 | MIT | fs |
| GDScript | PrestonKnopp/tree-sitter-gdscript | v6.0.0 | MIT | gd |
| Gleam | gleam-lang/tree-sitter-gleam | v1.1.0 | Apache-2.0 | |
| Go | tree-sitter/tree-sitter-go | v0.25.0 | MIT | golang |
| Haskell | tree-sitter/tree-sitter-haskell | v0.23.1 | MIT | hs |
| HCL | tree-sitter-grammars/tree-sitter-hcl | v1.2.0 | Apache-2.0 | terraform, tf |
| HTML | tree-sitter/tree-sitter-html | v0.23.2 | MIT | htm |
| Java | tree-sitter/tree-sitter-java | v0.23.5 | MIT | |
| JavaScript | tree-sitter/tree-sitter-javascript | v0.23.1 | MIT | js, jsx, mjs, cjs |
| JSON | tree-sitter/tree-sitter-json | v0.24.8 | MIT | |
| Kotlin | tree-sitter-grammars/tree-sitter-kotlin | v1.1.0 | MIT | kt |
| LaTeX | latex-lsp/tree-sitter-latex | v0.6.0 | MIT | tex |
| Lua | tree-sitter-grammars/tree-sitter-lua | v0.4.1 | MIT | |
| Makefile | tree-sitter-grammars/tree-sitter-make | v1.1.1 | MIT | make |
| Markdown | tree-sitter-grammars/tree-sitter-markdown | v0.5.2 | MIT | md |
| OCaml | tree-sitter/tree-sitter-ocaml | v0.24.2 | MIT | ml |
| Perl | tree-sitter-perl/tree-sitter-perl | ad74e6db | MIT | pl, pm |
| PHP | tree-sitter/tree-sitter-php | v0.24.2 | MIT | |
| Python | tree-sitter/tree-sitter-python | v0.23.6 | MIT | py |
| R | r-lib/tree-sitter-r | v1.2.0 | MIT | |
| Ruby | tree-sitter/tree-sitter-ruby | v0.23.1 | MIT | rb |
| Rust | tree-sitter/tree-sitter-rust | v0.24.0 | MIT | rs |
| Scala | tree-sitter/tree-sitter-scala | v0.24.0 | MIT | |
| SQL | DerekStride/tree-sitter-sql | v0.3.11 | MIT | |
| Swift | alex-pinkus/tree-sitter-swift | 0.7.1 | MIT | |
| TOML | tree-sitter-grammars/tree-sitter-toml | v0.7.0 | MIT | |
| TSX | tree-sitter/tree-sitter-typescript | v0.23.2 | MIT | |
| TypeScript | tree-sitter/tree-sitter-typescript | v0.23.2 | MIT | ts |
| XML | tree-sitter-grammars/tree-sitter-xml | v0.7.0 | MIT | |
| YAML | tree-sitter-grammars/tree-sitter-yaml | v0.7.2 | MIT | yml |
| Zig | tree-sitter-grammars/tree-sitter-zig | v1.1.2 | MIT | |

## Building Locally

```bash
# Build all grammars
./scripts/build-all.sh

# Build a single grammar
./scripts/build-grammar.sh javascript tree-sitter tree-sitter-javascript v0.25.0

# Verify universal binary
file dist/javascript.dylib
# Output: Mach-O universal binary with 2 architectures: [x86_64] [arm64]
```

## Contributing

See [CLAUDE.md](CLAUDE.md) for development guidelines.

## License

Build scripts and infrastructure: MIT

Individual grammars retain their original licenses (MIT or Apache-2.0). See `THIRD_PARTY_LICENSES.md` for details.

---

## Parking Lot

Languages we've investigated but can't include yet. These may be revisited when circumstances change.

| Language | Reason |
|----------|--------|
| LESS | WIP, known bugs, unmaintained |
| JSONC | Archived, read-only |
| T-SQL | No implementation exists |
| PowerShell | Archived July 2024, unmaintained |
| Groovy | No canonical repo, no releases |
| VBA | Only VB.NET available, not classic VBA |
| COBOL | Multiple competing, dialect coverage issues |
| Mojo | Too immature, multiple competing forks |
| Assembly | Fragmented (x86/ARM/generic), no unified grammar |
| MATLAB | Multiple competing, not in official org |
| Dart | Multiple competing, no canonical implementation |
| Prolog | AGPL-3.0 license incompatible with binary redistribution |
