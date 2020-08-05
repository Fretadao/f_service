# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased (master)
### Added
- Add `#on_success` and `#on_failure` hooks on Result objects.
- Link to Changelog on gemspec.

### Changed
- **[Deprecation]** Mark `Result#on` as deprecated. It will be removed on the next release. Use the`Result#on_success` and/or `Result#on_failure` hooks instead.

<!-- ### Removed -->

## 0.1.1
### Added
First usable version with:
- Result based services
- Type check on results
- Pattern matching with `#call`ables
- Safe chaining calls with `#then`

## 0.1.0
- **Yanked**