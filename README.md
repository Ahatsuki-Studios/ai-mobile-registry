# AI Mobile Registry

Public, signed **model metadata** registry for AI Mobile.

- Endpoint: https://ahatsuki-studios.github.io/ai-mobile-registry/v1/current.json
- Contains: signed catalog envelopes only (JSON metadata)
- Does **not** contain: model weights, private keys, passphrases, device identifiers

Clients verify envelopes with a compile-time pinned ECDSA P-256 public key
(keyId=aimobile-registry-2026-01) per ADR-0003 / ADR-0004 in the
[ai-mobile](https://github.com/Ahatsuki-Studios/ai-mobile) repository.

Rollback for clients requires publishing a **higher** corrected `registryVersion`;
never republish a lower version.
