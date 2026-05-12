---
name: mobile-app
description: Use when working on mobile app projects (React Native, Expo, Flutter, native) - auth, API compatibility, release flow, store submission, deep links
---

# Haye Skill: mobile-app

## Purpose
Build or maintain mobile apps with the API-compatibility, release pipeline and store-submission constraints that desktop projects don't have.

## User Response Language Rule
- Kullanıcı Türkçe yazıyorsa açıklamalar Türkçe verilir.

## Inputs to inspect first
1. Stack: React Native (bare or Expo), Flutter, native iOS (Swift), native Android (Kotlin).
2. Existing `app.json` / `app.config.ts` (Expo), `Info.plist` / `AndroidManifest.xml` for permissions.
3. Backend API contract used by the app.
4. Auth flow on mobile: in-app browser? PKCE? deep link return?
5. Release channel: TestFlight, Play Internal Testing, EAS, App Center.

## Core design rules

### API compatibility
- Mobile apps in the wild are slow to update; backend must keep old API versions working for at least 2–3 release cycles.
- Version the API path (`/v1/`, `/v2/`) or feature-flag by `app-version` header.
- Add fields, never remove. Removing a field is a breaking change.
- Servers tell the client when a force-update is needed (response header or dedicated endpoint).

### Auth
- OAuth: use PKCE (no client secret on mobile).
- Tokens: store in OS keychain (iOS) or EncryptedSharedPreferences (Android); never in AsyncStorage / SharedPreferences plain.
- Biometric unlock to re-access the token, not to authenticate to the server.
- Refresh token rotation; revoke old tokens server-side on rotation.
- Deep link return after OAuth: validate the state parameter; don't trust the URL.

### Permissions
- Request at point-of-use, not on launch.
- "Why we need this" explainer on first request screen.
- Always-on background location, camera, microphone, contacts — each requires a privacy-policy entry and a store-review justification.
- iOS 14+: ATT prompt for tracking; without it, no IDFA.
- Android 13+: notification permission must be requested; without it, push silently drops.

### Push notifications
- iOS: APNs token, server sends via APNs HTTP/2. Token rotates; refresh handler in app.
- Android: FCM token, same pattern.
- Per-user device table: `(user_id, device_id, platform, token, app_version, last_seen)`.
- On uninstall, token is invalid → server prunes on FCM/APNs unregister error.

### Deep links / universal links
- iOS Universal Links: requires `apple-app-site-association` file at `https://yourdomain/.well-known/...`.
- Android App Links: requires `assetlinks.json` at `/.well-known/assetlinks.json`.
- Test on actual devices; simulator behavior differs.
- Fallback: when app not installed, send to a web page; do not just 404.

### Release flow
- Version: `versionName` (semver, user-facing) and `versionCode` (integer, monotonic).
- iOS build number is also monotonic; can be `YYYYMMDDHHMM` style.
- TestFlight: internal testers (no review), external testers (small review).
- Play Internal Testing: small group, fast.
- Production release: staged rollout (5% → 20% → 50% → 100%) with kill-switch ready.

### Crash / observability
- Sentry / Firebase Crashlytics integrated; symbolicate `.dSYM` (iOS) and ProGuard mapping (Android).
- Custom keys: `app-version`, `user-id` (hashed if privacy matters), `network-type`.
- Don't ship verbose logs to prod; remote-toggle for debug builds only.

### Store submission gotchas
- iOS: rejected for missing privacy nutrition label, missing tracking declaration, login required but no sign-in-with-Apple option, in-app purchase using a non-Apple payment for digital goods.
- Android: target API level requirement (each year Google raises the minimum); apps below are rejected from updates.
- Both: contact info / support URL must work; "Login as test user" credentials needed in review.

### Offline / resilience
- Network not available: clear retry path, queued writes if applicable, never an infinite spinner.
- Optimistic UI for fast operations; revert with explicit error.
- Background sync respects OS battery rules; do not assume the app gets to run.

## Common pitfalls
- Backend breaking change deployed → users on old app version get 5xx; force-update flow saves you.
- Hardcoded API base URL in code → can't switch env without rebuild; use config layer.
- Pushing every event to analytics → battery drain; batch.
- Using web fonts on mobile → loading flash; bundle locally.
- iOS reviewer using a fresh account that hits an empty state nobody styled → invest in empty states.

## Output format
```markdown
## Stack
- framework / language:
- managed (Expo) or bare:

## API compatibility check
- versioning approach:
- force-update path:

## Auth posture
- token storage:
- refresh:
- biometric:

## Permissions
- requested:
- justifications:

## Release readiness
- versionName / versionCode:
- store metadata (privacy labels, support url):
- staged rollout plan:

## Findings (max 7)

## Recommended next 3 actions
```

## Safety rules
- Don't ship a production build without crash reporting.
- Don't enable a third-party SDK without checking what it sends and what its privacy policy says — the App Store will hold you responsible.
- Don't force-update users without a graceful screen explaining why.
- Long release plans go to `docs/mobile-release.md`; chat gets the summary.
