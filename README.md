# BudgetIQ

A production-grade personal finance app built with Flutter and Supabase. Track income and expenses, set budgets, manage savings goals, and get AI-powered spending insights — all with full offline support.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter 3, Material 3 |
| State | Riverpod 3 (code-gen) |
| Navigation | GoRouter |
| Backend | Supabase (Auth, PostgreSQL, RLS) |
| Offline cache | Hive CE (AES-encrypted) |
| Charts | fl_chart |
| Error tracking | Sentry (opt-in) |

---

## Prerequisites

- Flutter SDK ≥ 3.12
- A [Supabase](https://supabase.com) project with the migrations applied (see [Database setup](#database-setup))
- (Optional) A [Sentry](https://sentry.io) project DSN for crash reporting

---

## Local development setup

### 1. Clone and install dependencies

```bash
git clone https://github.com/your-org/budgetiq.git
cd budgetiq
flutter pub get
```

### 2. Configure environment

Copy the example config and fill in your credentials:

```bash
cp dart_define.example.json dart_define.json
```

Edit `dart_define.json`:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_REF.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_PUBLIC_KEY",
  "SENTRY_DSN": "",
  "GOOGLE_WEB_CLIENT_ID": "",
  "GOOGLE_IOS_CLIENT_ID": ""
}
```

The `GOOGLE_*` values are optional — leave them empty and the app simply hides
the "Continue with Google" button. To enable it, follow
[docs/google-sign-in-setup.md](docs/google-sign-in-setup.md).

> **Never commit `dart_define.json`** — it is listed in `.gitignore`. Only the `dart_define.example.json` template is tracked.

### 3. Run the app

```bash
flutter run --dart-define-from-file=dart_define.json
```

---

## Database setup

Apply the Supabase migrations in order:

```bash
supabase db push
```

Or apply manually via the Supabase dashboard SQL editor — migrations are in `supabase/migrations/`.

The migrations create:

| Migration | What it creates |
|---|---|
| 0001 | `profiles` (user preferences) |
| 0002 | `income_categories`, `expense_categories` |
| 0003 | `income_transactions`, `expense_transactions` |
| 0004 | Default category seed on sign-up |
| 0005 | `budgets`, `budget_categories` |
| 0006 | `goals`, `goal_contributions` |
| 0007 | Soft delete on `budget_categories` |
| 0008 | Display names from Google sign-in |

All tables have Row Level Security (RLS) enabled — users can only access their own data.

---

## Data loading and offline behaviour

The app never loads a user's entire history. On open it fetches a rolling
window of the last **13 months** of transactions (capped at 2,000 rows) — wider
than anything the analytics need — and pages in older history 200 rows at a time
behind *Load older transactions*. Everything loaded is cached in Hive for
offline reads.

Writes are offline-first: they apply to the cache immediately and go into a
durable outbox that drains when connectivity returns.

- **Conflicts** use last-write-wins. An update carries the `updated_at` it was
  based on; if the server row moved on since, the server wins and the queued
  edit is dropped.
- **Rejected writes** (validation, permission) cannot succeed on retry, so they
  are dropped from the queue *and* recorded as dead letters. The sync banner
  reports them until the user acknowledges it, so a change never silently
  disappears.

## Security

- The Hive cache holds financial data, so it is encrypted with a 256-bit AES key
  held in the platform keystore (Android KeyStore / iOS Keychain, device-only)
  via `flutter_secure_storage`. See `lib/core/cache/cache_encryption.dart`.
- Cache keys are namespaced per user (`u:<user id>:<key>`), and signing out
  purges that user's entries — cached data cannot leak to the next account on a
  shared device.
- All Supabase tables enforce Row Level Security; users can only read and write
  their own rows.
- Optional biometric unlock gates the app on launch and on return from the
  background.

## Continuous integration

`.github/workflows/ci.yaml` runs on every push and pull request: formatting
check, generated-code freshness, `flutter analyze --fatal-infos`, the test suite
with coverage, and a release APK build.

## Running tests

```bash
flutter test
```

Target: ≥ 80% coverage on business logic. Run with coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Android release build

### 1. Generate a signing key (first time only)

```bash
keytool -genkey -v \
  -keystore android/budgetiq-release.jks \
  -alias budgetiq \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Keep `budgetiq-release.jks` secure — **never commit it**. It is covered by `.gitignore`.

### 2. Create `android/key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=budgetiq
storeFile=../budgetiq-release.jks
```

This file is also gitignored.

### 3. Build the release APK / AAB

```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --dart-define-from-file=dart_define.json

# APK (for direct distribution)
flutter build apk --dart-define-from-file=dart_define.json
```

---

## iOS release build

### Bundle identifier

The iOS bundle identifier is set in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities**
3. Set **Bundle Identifier** to `com.budgetiq.budgetiq`
4. Configure your Apple Developer Team

The Xcode project already has `PRODUCT_BUNDLE_IDENTIFIER = com.budgetiq.budgetiq` set in all build configurations.

### Build

```bash
flutter build ipa --dart-define-from-file=dart_define.json
```

---

## Project structure

```
lib/
├── core/          # Router, theme, error types, sync engine, config
├── features/      # 12 feature modules (auth, transactions, budgets, …)
├── shared/        # Money type, TransactionKind, common widgets
└── main.dart

supabase/
└── migrations/    # 8 ordered SQL migration files

test/
├── core/          # Sync engine, validation
├── features/      # Repository, usecase, domain service tests
└── shared/        # Money, Month, widget tests
```

---

## Environment variables reference

| Variable | Required | Description |
|---|---|---|
| `SUPABASE_URL` | Yes | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anon/public key |
| `SENTRY_DSN` | No | Sentry DSN for crash reporting (leave empty to disable) |
| `GOOGLE_WEB_CLIENT_ID` | No | Google OAuth **web** client ID; enables Google sign-in ([setup](docs/google-sign-in-setup.md)) |
| `GOOGLE_IOS_CLIENT_ID` | No | Google OAuth **iOS** client ID; required for Google sign-in on iOS |

Pass via `--dart-define-from-file=dart_define.json` or individually with `--dart-define=KEY=VALUE`.

---

## License

Private. All rights reserved.
