## What changed

<!-- What this PR does and why. Link an issue if there is one. -->

## Type of change

<!-- Keep only what applies. It must match the Conventional Commit type in the PR title. -->

- [ ] `feat` — new capability *(triggers a minor release)*
- [ ] `fix` — bug fix *(triggers a patch release)*
- [ ] `refactor` — behaviour-preserving change *(no release)*
- [ ] `chore` / `ci` / `docs` / `test` / `style` — maintenance *(no release)*
- [ ] breaking change — `!` in the title or a `BREAKING CHANGE:` footer

## Checklist

- [ ] The **PR title** is a valid Conventional Commit (`type: short description`).
      This PR is squash-merged, so the title is the commit release-please reads to
      decide the next version and to write the `CHANGELOG.md`. A workflow checks it.
- [ ] `bundle exec rake` and `bundle exec rubocop --parallel` pass locally.
- [ ] New behaviour ships with specs.
- [ ] The `CHANGELOG.md` was **not** edited by hand; release-please owns it.
- [ ] A breaking change is flagged with `!` or a `BREAKING CHANGE:` footer, and the
      README says what to use instead.

<!-- See CONTRIBUTING.md for the commit conventions and the release flow. -->
