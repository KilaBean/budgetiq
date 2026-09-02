# Google Sign-In setup

BudgetIQ uses the **native** Google account picker (Credential Manager on
Android, the Google SDK on iOS) and exchanges the resulting OIDC **ID token**
for a Supabase session via `signInWithIdToken`. There is no browser round-trip
and no OAuth redirect to configure.

One button covers both sign-in and sign-up: Supabase creates the user on first
use of a given Google identity, and the `on_auth_user_created` trigger
(migration `0004`, refined in `0008`) seeds their profile and starter
categories exactly as it does for email sign-ups.

Until `GOOGLE_WEB_CLIENT_ID` is set at build time, `AppConfig.hasGoogleSignIn`
is `false` and the button is not rendered — an unconfigured build never shows
an option that cannot work.

---

## 1. Google Cloud Console

In [console.cloud.google.com](https://console.cloud.google.com) → **APIs &
Services**:

1. Configure the **OAuth consent screen** (External, app name, support email,
   and the `email` / `profile` / `openid` scopes).
2. Under **Credentials → Create credentials → OAuth client ID**, create:

| Client type | Needed for | Fields |
|---|---|---|
| **Web application** | Both platforms — this is the audience Supabase validates the ID token against | Authorized redirect URI: `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback` |
| **Android** | Android only | Package name `com.budgetiq.budgetiq` (and `com.budgetiq.budgetiq.dev` for the dev flavor) + SHA-1 fingerprint |
| **iOS** | iOS only | Bundle ID of the Runner target |

### Android SHA-1 fingerprints

Create one Android client per signing certificate you use — at minimum the
debug key and the release key.

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For the release key, use the keystore referenced by `android/key.properties`.
If you ship through Play App Signing, also add the **App signing key**
fingerprint from the Play Console (Setup → App integrity).

> The Android client ID never appears in the app's config — Google resolves it
> from the package name plus certificate fingerprint. Only the **web** client
> ID is passed to the app.

---

## 2. Supabase

Dashboard → **Authentication → Providers → Google**:

1. Enable the provider.
2. **Client ID**: the *web* client ID.
3. **Client secret**: the *web* client secret.
4. Expand **Authorized Client IDs** and add the **web**, **Android**, and
   **iOS** client IDs — Supabase rejects an ID token whose `aud` is not listed
   here.

Apply migration `0008_google_profile_names.sql` so Google users get their real
name as their profile display name instead of the email local-part.

---

## 3. App configuration

Add the client IDs to `dart_define.json`:

```json
{
  "GOOGLE_WEB_CLIENT_ID": "1234-abcd.apps.googleusercontent.com",
  "GOOGLE_IOS_CLIENT_ID": "1234-efgh.apps.googleusercontent.com"
}
```

`GOOGLE_IOS_CLIENT_ID` may be left empty for Android-only builds.

### iOS: URL scheme

iOS additionally needs the **reversed** iOS client ID registered as a URL
scheme. Take `GOOGLE_IOS_CLIENT_ID`, reverse its dot-separated segments, and
add a second entry to `CFBundleURLTypes` in `ios/Runner/Info.plist` (a comment
in that file marks the spot):

```xml
<dict>
  <key>CFBundleTypeRole</key><string>Editor</string>
  <key>CFBundleURLSchemes</key>
  <array>
    <string>com.googleusercontent.apps.1234-efgh</string>
  </array>
</dict>
```

### Android

No manifest changes are required. `minSdk` is already 23, above the 21 that
`google_sign_in` 7.x needs.

---

## 4. Verify

```bash
flutter run --dart-define-from-file=dart_define.json
```

Tap **Continue with Google** on the auth screen. On success the router
redirects to onboarding (first run) or the dashboard.

## Troubleshooting

| Symptom | Cause |
|---|---|
| The button does not appear | `GOOGLE_WEB_CLIENT_ID` is empty — the dart-defines were not passed |
| "Google sign-in is not enabled for this app yet." | The Google provider is disabled in Supabase |
| "Google sign-in could not be verified." | The token's `aud` is not in Supabase's **Authorized Client IDs** |
| "Google did not return an ID token." | No Android/iOS OAuth client matches this package name + SHA-1, or `serverClientId` is wrong |
| Picker opens, then nothing happens | Expected when the user dismisses it — cancellation is silent by design |
| Works in debug, fails in release | The release (or Play App Signing) SHA-1 is missing from the Android OAuth client |
