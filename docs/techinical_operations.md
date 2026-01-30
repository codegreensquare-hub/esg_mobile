# ESG Mobile — Technical Operations

This document describes how to deploy, operate, monitor, and back up the ESG Mobile application.

## System Overview

**Client apps**

- Flutter app targeting Web (Netlify), Android, iOS, macOS, Windows.

**Backend / services**

- **Supabase**: primary backend (Postgres, Auth, Storage, RPC functions, migrations in `supabase/migrations`).
- **Firebase**: Firebase Core + Firebase Cloud Messaging (FCM) for push notifications.
- **PortOne/Iamport**: payments
  - Mobile: `portone_flutter` (`IamportPayment`)
  - Web: `https://cdn.iamport.kr/v1/iamport.js` loaded in `web/index.html`

**Web hosting**

- **Netlify** serves the built Flutter Web output (`build/web`).
- A small Netlify Function (`/.netlify/functions/config`) provides non-secret runtime configuration for Web (Supabase URL + anon key).

## Environments

This repo supports at least:

- **Local dev**: `.env` present in repo root (loaded at app startup).
- **Web production**: Netlify build + runtime config via Netlify env vars and `/.netlify/functions/config`.

Environment selection:

- `MODE` can be set to values like `DEV`/`DEVELOPMENT` to enable PortOne dev behaviors.

## Configuration & Secrets

### What must NOT be treated as secret

- **Supabase anon key**: safe to ship to clients (it is expected to be public), but it still grants whatever your RLS policies allow.

### What MUST be treated as secret

- Supabase **service role** key (must never ship to clients).
- Any private API keys used server-side.

### Local configuration

Local runs load `.env` (see `lib/main.dart`):

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

PortOne also reads from `.env` (mobile) and from `.env`/`--dart-define` (web builds):

- `MODE`
- `PORTONE_V1_USER_CODE` (+ `PORTONE_V1_USER_CODE_DEV`)
- `PORTONE_V1_PG` (+ `PORTONE_V1_PG_DEV`)
- `PORTONE_V1_TEST_AMOUNT` (dev-only)
- `PORTONE_APP_SCHEME` (mobile-only; default `esgmobile`)

### Netlify configuration (Web)

Netlify builds use:

- `netlify.toml` → build command `bash ./netlify-build.sh`, publish `build/web`
- `netlify-build.sh` installs Flutter, runs `flutter pub get`, and builds Web with `--dart-define` values.

Important behaviors:

- During Netlify builds, `.env` is overwritten with empty placeholders (to avoid leaking values into build artifacts).
- For Web runtime, `lib/main.dart` fetches `/.netlify/functions/config` if `.env` lacks Supabase values.

Netlify environment variables required:

- `SUPABASE_URL` (used by Netlify function)
- `SUPABASE_ANON_KEY` (used by Netlify function)

Optional Netlify environment variables that become `--dart-define` at build time:

- `MODE`
- `PORTONE_V1_USER_CODE`
- `PORTONE_V1_USER_CODE_DEV`
- `PORTONE_V1_PG`
- `PORTONE_V1_PG_DEV`
- `PORTONE_V1_TEST_AMOUNT`

Note:

- `--dart-define` values are compiled into the Web bundle. Do not put secrets there.

## Deployments

### Web deployment (Netlify)

**Build & deploy path**

- Netlify deploys `build/web` produced by `flutter build web --wasm`.

**Operational checklist**

- Confirm Netlify env vars are set (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, and any PortOne defines needed).
- Confirm Supabase project is reachable from Netlify (no restrictive network rules).
- Confirm `/.netlify/functions/config` returns correct values (should return JSON).
- Smoke test:
  - App loads
  - Login works
  - Read operations (products/stories/missions) work
  - Checkout flow reaches PortOne in the intended environment (DEV vs PROD)

**Rollback**

- Use Netlify “Deploys” → “Published deploy” rollback to a previous successful deploy.

### Mobile deployment (Android/iOS)

Mobile builds typically require a secure CI/CD setup and store-specific release processes.

**Android**

- Ensure `android/app/google-services.json` is present (Firebase).
- Build artifacts:
  - Debug: `flutter run`
  - Release (recommended): `flutter build appbundle`

**iOS**

- Ensure `ios/Runner/GoogleService-Info.plist` is present (Firebase).
- Typical release artifact: `flutter build ipa` (requires signing).

**PortOne mobile considerations**

- `PORTONE_APP_SCHEME` must match the app scheme configured for the app.

## Database & Migrations (Supabase)

Migrations live in `supabase/migrations`.

Notable server-side behavior:

- `checkout_cart(...)` RPC is `SECURITY DEFINER` and performs checkout logic.
- Mission analytics logging uses RPC functions `log_mission_impression` and `log_mission_click` with throttling.
- Mission participation triggers award points transactions on approval.

**Recommended migration workflow**

1. Apply migrations to a staging/dev Supabase project first.
2. Verify RLS and grants (especially for `SECURITY DEFINER` functions).
3. Run smoke tests from the app (checkout, mission participation approval paths).
4. Apply to production.

**Rollback approach**

- Prefer a forward-only “revert migration” that undoes the change.
- Avoid manual edits in the Supabase UI that are not tracked in migrations.

## Monitoring & Logging

### Netlify

- Monitor Netlify build failures and deploy status.
- Monitor Netlify Function logs for `/.netlify/functions/config` (should be stable, fast, and always return 200).

Alert suggestions:

- Build failures (notify Slack/email).
- Elevated 4xx/5xx (if you add analytics/edge logs).

### Supabase

- Monitor:
  - Postgres health (connections, CPU, storage)
  - API error rates
  - Auth failures/spikes
  - Slow queries (especially around checkout and mission tables)
- Use Supabase logs and advisors regularly, especially after migrations.

### Push notifications (Firebase FCM)

- The app requests notification permission and saves the FCM token to Supabase (`push_notification_token` table).
- Monitor in Firebase Console:
  - Messaging delivery issues
  - Token churn (if you add tracking)

### Client error monitoring (recommended)

There is no dedicated crash/error reporting tool configured in this repo beyond debug logs.
Recommended additions:

- Firebase Crashlytics (mobile)
- Sentry (web/mobile)

## Backups & Disaster Recovery

### Supabase Postgres

Primary data lives in Supabase Postgres.

Backup guidance:

- Ensure automated backups / point-in-time recovery are enabled for production.
- Take a manual backup before high-risk migrations.

Restore drill (recommended quarterly):

1. Restore a backup to a new Supabase project/branch.
2. Point a staging build at the restored environment.
3. Validate critical paths: auth, product browsing, checkout RPC, award points.

### Supabase Storage

The app uses Supabase Storage public URLs for images.
Backup guidance:

- Ensure storage buckets and objects are included in your backup plan.
- If business-critical, schedule periodic exports of buckets to external storage.

### Netlify

Netlify is stateless hosting for Web build artifacts.
DR plan:

- Keep Netlify site configuration (env vars, build settings) documented.
- Repo + Netlify config recreate is straightforward if needed.

### Firebase

Firebase is used for messaging configuration.
DR plan:

- Ensure Firebase project ownership/access is shared with operations.
- Maintain documented steps for rotating keys and re-provisioning APNs (iOS).

## Operational Runbooks

### Incident: Web app fails to load

1. Check Netlify Deploy status and recent deploy logs.
2. Validate `/.netlify/functions/config` returns 200 and includes `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. Check Supabase status and API logs for spikes.
4. Roll back to last known-good Netlify deploy if needed.

### Incident: Checkout failures

1. Check client logs (browser console / device logs).
2. Confirm Supabase `checkout_cart` function exists and permissions are correct.
3. Confirm PortOne env config (`MODE`, user code, pg) is correct for the environment.
4. If a migration introduced the issue, apply a revert migration and redeploy.

### Incident: Push notifications not arriving

1. Confirm user granted notification permission.
2. Confirm token is being saved/upserted in Supabase (`push_notification_token`).
3. Validate Firebase project configuration for the target platform.
4. Verify downstream sending service (not present in this repo) is using valid tokens.

## Related docs

- Database schema ERD: `docs/database_schema.md`
- Sample ERD subset: `docs/erd_diagram.md`
