# Change Log
All notable changes to this project will be documented in this file.


## [Unreleased][unreleased]
### Fixed

### Added
- `:complete` builtin generates bash autocomplete function: `eval "$(gun :complete)"`

- Auto-export for module functions starting with `cmd:`
- `:complete` builtin generates bash autocomplete function: `eval "$(gun :complete)"`

### Removed

### Changed

## [0.1.0] - 2015-07-02
### Fixed
- Resolved issue where `deps-install` download URL has a redirect
- Ensure `gun-find-root` changes working directory to $GUN_ROOT

### Added
- `-t` and `--trace` as last argument, enables `-x` closer to command
- Basic test coverage
- Build artifacts on CircleCI, including Go workspace
- Calling help explicitly will show second level commands
- `GUN_PATH` used for module sourcing with `PATH`-like semantics
- Added some initial remote module libraries

### Removed

### Changed
- Deprecated `GUN_MODULE_PATH` in favor of `GUN_PATH`
- Standard error used for warnings and errors
- Static compilation of binary
- `version` builtin command is now `:version`
- `help` builtin command is now `:help`
- `update` builtin command is now `:update`
- `env` builtin command is now `:env`
- `fn` builtin command is now `::`

## [0.0.7] - 2015-02-20
### Added
- Support for `Gunfile` as global module / profile
- Support for projects without profiles, just `Gunfile`
- Support for `init()` in profiles and `Gunfile`
- Support for `-h` and `--help` as last argument
- `.gun` and `Gunfile.*` added to `.gitignore` on `gun init`

### Removed
- Stopped listing second level commands

### Changed
- Using `Gunfile` to detect glidergun project instead of `.gun`
- Profiles now use `Gunfile.<name>` instead of `.gun_<name>`

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

[unreleased]: https://github.com/gliderlabs/glidergun/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/gliderlabs/glidergun/compare/v0.0.7...v0.1.0
[0.0.7]: https://github.com/gliderlabs/glidergun/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/gliderlabs/glidergun/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/gliderlabs/glidergun/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/gliderlabs/glidergun/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/gliderlabs/glidergun/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/gliderlabs/glidergun/compare/v0.0.1...v0.0.2
