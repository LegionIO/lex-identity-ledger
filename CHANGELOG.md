# Changelog

## [0.1.1] - 2026-05-08

### Changed
- Updated identity runner to write to `identity_principals` table (was `principals`) with `uuid` and `provider_identity_key` columns.
- Updated groups runner to write to `identity_principals` with `uuid` columns for groups and memberships.
- Updated test_db schema to match consolidated identity tables.

## [0.1.0] - 2026-05-07

### Added
- Initial release with identity, groups, and audit runners.
