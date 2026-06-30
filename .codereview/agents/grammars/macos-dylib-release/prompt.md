Review only for issues that could break or invalidate the macOS universal tree-sitter dylib release path used by SwiftMarkdown.

Prioritize 0-5 findings. Return no findings when the diff is acceptable. Avoid style feedback unless it hides a release-integrity problem.

Focus on:
- License compatibility for bundled or redistributed grammar artifacts.
- `grammars.json` metadata correctness, including tag, SHA, subpath, `requiresGeneration`, and any assumptions about generated parser sources.
- Scripts and workflows that download, build, package, checksum, size, version, or publish artifacts.
- macOS universal build behavior: both `arm64` and `x86_64`, merge/package steps, and any architecture-specific gaps.
- Query copying and packaging completeness.
- Manifest checksum and size accuracy.
- Release triggers, version bumps, and artifact naming expected by SwiftMarkdown.

Flag only concrete, user-impacting problems. If behavior is acceptable, return no findings.
