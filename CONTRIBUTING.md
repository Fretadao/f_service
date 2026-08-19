# Contributing

Bug reports and pull requests are welcome. This document covers the conventions the
release automation depends on, so a contribution does not get stuck on them.

## Development setup

Run `bin/setup` once after cloning. It installs dependencies and points
`core.hooksPath` at `.githooks/`, enabling a `commit-msg` hook that enforces
Conventional Commits locally.

Run the tests and the linter the same way CI does:

```bash
bundle exec rake
bundle exec rubocop --parallel
```

## Commit messages — Conventional Commits

This project follows [Conventional Commits](https://www.conventionalcommits.org/).
The version bump and the `CHANGELOG.md` are generated automatically from commit
messages, so the prefix matters:

| Type | When to use | Release effect |
|------|-------------|----------------|
| `feat:` | New capability | minor bump |
| `fix:` | Bug fix | patch bump |
| `feat!:` or a `BREAKING CHANGE:` footer | Backwards-incompatible change | minor bump while `0.x`, major from `1.0` on |
| `chore:` `ci:` `docs:` `style:` `test:` `refactor:` | Maintenance | no release |

Pull requests are squash-merged, so **the PR title becomes the commit message**
release-please reads. Get the title right even when the individual commits are
messy — a workflow checks it on every pull request.

## Deprecating something

This gem is public, so nothing user-facing is removed without warning first. The cycle is
deprecate, ship at least one release with the warning, then remove in a release that says so.

**1. Mark it.** Keep the method working and warn from inside it. `FService.deprecate!` exists
for exactly this and prints a message pointing at the replacement, including the caller:

```ruby
# @deprecated Use {#Success} instead.
def success(data = nil)
  FService.deprecate!(
    name: "#{self.class}##{__method__}",
    alternative: '#Success',
    from: caller[0]
  )

  Result::Success.new(data)
end
```

For an argument rather than a whole method, use `FService.deprecate_argument_name`:

```ruby
FService.deprecate_argument_name(
  name: 'mock_service',
  argument_name: :type,
  alternative: 'mock_service(..., types: [:created])',
  from: caller[0]
)
```

Add the `@deprecated` YARD tag too — it shows up in the API docs on RubyDoc.

**2. Ship it.** A commit that only deprecates is a `feat:` (new warning, nothing breaks) and
goes out in a normal minor release. Say in the commit body what replaces it.

**3. Remove it, later.** In a separate release, drop the method and its specs, and use
`feat!:` with a `BREAKING CHANGE:` footer so release-please bumps accordingly and writes the
`⚠ BREAKING CHANGES` section. Grep the README for the removed name — documentation that still
promises the old API is worse than no documentation.

> Do not skip the middle step. `#success`, `#failure` and `#result` were deprecated in 0.2.0
> with a note saying they would go "on the next release", and were only removed in 0.4.0 —
> three releases later. Better to over-warn than to break someone quietly.

The two `FService.deprecate*` helpers sit unused between deprecations. That is expected: they
are the tooling for this process, not dead code, and the next deprecation picks them up again.

## Releasing (release-please)

Releases are automated with [release-please](https://github.com/googleapis/release-please);
there is no version to edit and no release command to run by hand.

1. Every push to `master` creates or updates a **release PR** titled
   `chore(master): release X.Y.Z`. It bumps `lib/f_service/version.rb`,
   `.release-please-manifest.json`, `Gemfile.lock` and the version in the README
   install snippet, and updates `CHANGELOG.md` from the Conventional Commits made
   since the last release.
2. **Do not edit `CHANGELOG.md` by hand.** release-please owns it.
3. **Merging the release PR** creates the git tag `vX.Y.Z` and a GitHub Release.
   That triggers `.github/workflows/publish.yml`, which publishes the gem to
   RubyGems through [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/)
   — OIDC, with no API key stored in this repository.
4. The release PR always reflects **everything on `master` since the last
   release**. Cut releases promptly: merge the release PR before landing
   unrelated work you don't want included in that release.

## If the release PR is failing

release-please only rebuilds the release branch when a **releasable** commit
(`feat:` / `fix:`) lands on `master`. Non-releasable commits (`chore:`, `ci:`,
`docs:`, `style:`, `test:`) do **not** rebuild it, so the release branch can fall
behind `master` and its CI can run stale code.

When the release PR's CI is red:

1. Push the fix to `master` through a normal PR. **Never** push directly to the
   `release-please--…` branch — release-please overwrites it.
2. If those fix commits are non-releasable (so the release PR won't refresh on its
   own), **close the release PR and delete its branch**. On the next push to
   `master`, release-please recreates it from the current `master`.
3. Merge the freshly recreated release PR.

Never manually rebase or force-push the release-please branch.

## If the gem was not published

The tag and the GitHub Release already exist, so publishing is retryable: fix the
cause and use **Re-run jobs** on the failed `Publish gem` workflow run. An
authentication failure points at the trusted publisher registration on RubyGems
(the repository and the workflow filename must match `publish.yml`), not at the
workflow itself.
