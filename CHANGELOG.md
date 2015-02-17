# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased][unreleased]
### Fixed

### Added

### Removed

### Changed

## [0.0.6] - 2015-02-16
### Fixed
- Resolved issue where `deps-require` downloads wrong binary

### Changed
- Switched from shunit2 to simpler test system

## [0.0.5] - 2015-02-11
### Fixed
- Avoid use of system `md5` by using baked-in `checksum`
- Ensure `chmod +x` on downloaded binaries in deps.bash
- `gun init` no longer breaks `.gitignore`

### Added
- `gun update` which performs a self-update to latest release
- `gun version` also displays latest released version if different

### Changed
- `gun init` makes `.gun` with its own `.gitignore`

## [0.0.4] - 2015-02-09
### Fixed
- Use bash from PATH
- Fix single quoting in environment variables

## [0.0.3] - 2015-02-09
### Fixed
- Fixed profile loading logic

### Added
- Added basic colored output helpers
- Added `fn-source` function

### Removed
- Dropped bindata.go from versioned source

### Changed
- Changed `env-export` to `env-import`, now allows default value
- Checksum checking is skipped if index provides none
- `show-env` (`env` subcommand) output is better aligned

## [0.0.2] - 2015-02-04
### Fixed
- Fixed profiles not loading

[unreleased]: https://github.com/gliderlabs/glidergun/compare/v0.0.6...HEAD
[0.0.6]: https://github.com/gliderlabs/glidergun/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/gliderlabs/glidergun/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/gliderlabs/glidergun/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/gliderlabs/glidergun/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/gliderlabs/glidergun/compare/v0.0.1...v0.0.2
