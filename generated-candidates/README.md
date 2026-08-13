# Generated candidates (unsigned) — local only

Deterministic **unsigned** schema-v3 catalog payloads produced by
`registry-prepare generate` / `tools/prepare-v3-candidate.bat`.

These files are **gitignored** local build output. They are **not** the
public signed feed and must not be committed.

Why: GitHub Pages for this repo publishes from `main` at repository root
(`/`). Anything committed under `generated-candidates/` would become
web-accessible after push.

Authoring SSoT (versioned):

`registry-source/production-v3/catalog.json`

Public signed target (M5.2b only):

`v1/catalog-schema-v3/current.json`
