# AI Mobile Registry

Public, signed **model metadata** registry for AI Mobile.

- Legacy v2 endpoint: https://ahatsuki-studios.github.io/ai-mobile-registry/v1/current.json
- Future v3 endpoint: https://ahatsuki-studios.github.io/ai-mobile-registry/v1/catalog-schema-v3/current.json
- Contains: signed catalog envelopes only (JSON metadata)
- Does **not** contain: model weights, private keys, passphrases, device identifiers

## GitHub Pages

Pages is configured as **legacy** publish from branch `main`, path `/` (repository root).
Anything committed on `main` is potentially web-accessible after push.

## Authoring (M5.2+)

Publication SSoT is **not** the signed envelope.

```
registry-source/production-v3/catalog.json   (versioned authoring SSoT)
  → validate (ModelCatalogParser + ProductionPublishPolicy)
  → generate deterministic unsigned payload
  → generated-candidates/*.json              (LOCAL / gitignored)
  → (M5.2b) production-sign → v1/catalog-schema-v3/current.json
```

Unsigned candidates are **gitignored** so an ordinary `git add .` cannot publish them.
Authoring source under `registry-source/` remains versioned.

See `docs/M5.2-PRODUCTION-SIGNING.md` and `tools/prepare-v3-candidate.bat`.

Clients verify envelopes with a compile-time pinned ECDSA P-256 public key
(keyId=aimobile-registry-2026-01) per ADR-0003 / ADR-0004 in the
[ai-mobile](https://github.com/Ahatsuki-Studios/ai-mobile) repository.

Rollback for clients requires publishing a **higher** corrected `registryVersion`
**within the same feed**; never republish a lower version for that feed.
