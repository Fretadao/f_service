# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased (master)
### Added
- Add `catch` to `Failure` and `Success`. It acts as an inverted `then`.
- Add support to multiple type checks on `Result#on_success` and `Result#on_failure` hooks.
- Yields result type on blocks (`then`, `on_success` and `on_failure`).
- Add type check on `Result#on_success` and `Result#on_failure` hooks.
- Add method `Base#Try`. It wraps exceptions in Failures.
- Add method `Base#Check`. It converts booleans to Results.
- Add methods `#Success(type, data:)` and `#Failure(type, data:)` on `FService::Base`.
  These methods allow defining the type and value of the Result object.
- Allow adding types on `Result`s.
- Add `#on_success` and `#on_failure` hooks on Result objects.
- Link to Changelog on gemspec.

### Changed
- **[Deprecation]** Mark `Base#result` as deprecated. They will be removed on the next release. Use the `Base#Check` instead.
- **[Deprecation]** Mark `Base#success` and `Base#failure` as deprecated. They will be removed on the next release. Use the `Base#Success` and `Base#Failure` instead.
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
