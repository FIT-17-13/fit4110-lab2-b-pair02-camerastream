# VERSIONING

## Principle

This repository follows semantic versioning for contract changes:

- `MAJOR.MINOR.PATCH`
- `MAJOR` changes when the contract introduces incompatible API changes.
- `MINOR` changes when new compatible paths, schemas, or examples are added.
- `PATCH` changes when documentation, examples, or non-breaking clarifications are updated.

## Versioning rules

- Contract changes require a new release entry in the repository.
- Any change to request/response shapes, status codes, or required fields is a `MINOR` or `MAJOR` update.
- Documentation-only updates or fix to examples are `PATCH`.

## Release process

1. Update `openapi.yaml` and ensure the contract remains valid.
2. Run Spectral lint with `campus-spectral.yaml` and fix all errors.
3. Start Prism mock server and verify the API mock on port `4010`.
4. Create or update `evidence/buoi-02/spectral-report.txt` with the lint report.
5. Update negotiation log and docs for the current version.
6. Tag release according to Semantic Versioning.

## Compatibility

- Maintain backward compatibility for existing Consumer fields whenever possible.
- Use new schema versions or separate endpoints for breaking changes.
- Keep error and authentication handling stable across minor releases.
