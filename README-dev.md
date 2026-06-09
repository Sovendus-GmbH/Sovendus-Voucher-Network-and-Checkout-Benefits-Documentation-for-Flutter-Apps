# Developer / Release Guide

This package is published to [pub.dev](https://pub.dev/packages/sovendus_voucher_network_and_checkout_benefits)
via **GitHub Actions**. There are two workflows:

- **`.github/workflows/ci.yml`** — runs on every pull request and push to `main`:
  `flutter pub get` → format check → `flutter analyze` → `flutter test`.
- **`.github/workflows/publish.yml`** — runs when a `v*` git tag is pushed and publishes
  the package to pub.dev using **OIDC** (no API tokens or secrets are stored in GitHub).

## One-time setup (pub.dev admin, required before the first tagged publish)

A pub.dev **admin/uploader** of this package must enable automated publishing once:

1. Go to the package page on pub.dev → **Admin** tab → **Automated publishing**.
2. Enable **Publishing from GitHub Actions**.
3. Repository: `Sovendus-GmbH/Sovendus-Voucher-Network-and-Checkout-Benefits-Documentation-for-Flutter-Apps`
4. Tag pattern: `v{{version}}`

The tag pattern means a tag `v1.4.0` is only allowed to publish pubspec `version: 1.4.0` —
if they don't match, pub.dev rejects the publish.

If you are not yet an uploader on the `sovendus.com` publisher, ask an existing admin to add you.

## Releasing a new version

1. Bump `version:` in `pubspec.yaml`.
2. Add a matching section to `CHANGELOG.md` (pub.dev requires the new version to be documented).
3. Merge to `main` (CI must be green).
4. Tag and push:
   ```bash
   git tag v1.4.0          # must equal the pubspec version
   git push origin v1.4.0
   ```
5. The **Publish to pub.dev** workflow runs, validates with `dart pub publish --dry-run`,
   then publishes. Confirm the new version appears on pub.dev.

## Local checks before pushing

```bash
flutter pub get
dart format .                 # fix formatting (CI enforces this)
flutter analyze
flutter test
dart pub publish --dry-run    # validate packaging without uploading
```

> Note: the CI format step (`dart format --set-exit-if-changed`) will fail if the code is not
> formatted. If it fails on the first run, run `dart format .` once and commit the result.
