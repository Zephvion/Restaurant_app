# PARAGON — Restaurant App (Flutter frontend)

A pixel-faithful Flutter frontend for the **PARAGON** restaurant app, built from
the provided Figma designs. **Frontend only** — no backend. All content is
in-app mock data.

> This is **Set 1** of the app: Splash → Onboarding → Login / Sign Up → OTP →
> Home (services grid). The **Order Food** flow is stubbed with a placeholder
> screen and will be built when the next set of designs is provided.

## What's included

| Screen | File |
| --- | --- |
| Splash (PARAGON crest) | `lib/screens/splash/splash_screen.dart` |
| Onboarding (3 slides) | `lib/screens/onboarding/onboarding_screen.dart` |
| Login ("Welcome Back!") | `lib/screens/auth/login_screen.dart` |
| Sign Up ("Create a new account") | `lib/screens/auth/signup_screen.dart` |
| OTP ("Verify OTP!") | `lib/screens/auth/otp_screen.dart` |
| Home / Services grid | `lib/screens/home/home_screen.dart` |
| Order Food (placeholder) | `lib/screens/order_food/order_food_placeholder.dart` |

Reusable pieces live in `lib/widgets/` (buttons, text fields, OTP boxes, the
painted Google "G", the painted PARAGON crest, and a network-image widget with
an offline fallback). Colors, spacing, radii and typography are centralized in
`lib/theme/`.

## Navigation flow

```
Splash ──▶ Onboarding ──▶ Login ⇄ Sign Up
                             │        │
                             ▼        ▼
                           Home  ◀── OTP
                             │
                             ▼
                       Order Food (placeholder)
```

- **Login** → any non-empty email/password routes to **Home**.
- **Sign Up** → valid form routes to **OTP** (the phone you type is shown there).
- **OTP** → the "Sign In" button appears once all 4 digits are entered.
- On **Home**, tapping **Order Food** opens the placeholder; the other tiles
  show a "coming soon" snackbar.

## Running it

This repository contains the Dart source (`lib/`), `pubspec.yaml`, and assets —
but **not** the platform folders (`android/`, `ios/`, `web/`, …). Generate them
once with `flutter create`, which adds the missing platform scaffolding without
touching your `lib/` code:

```bash
cd restaurant_app
flutter create .          # adds android/ios/web folders (keeps lib/ intact)
flutter pub get           # fetches dependencies
flutter run               # launch on a connected device / emulator
```

Requirements: Flutter 3.10+ (Dart 3.0+). Verify your setup with `flutter doctor`.

### Notes

- **Fonts:** typography uses `google_fonts` (Quicksand for headings, Poppins for
  body). Fonts download on first launch, so the first run needs an internet
  connection. To ship fully offline, download the `.ttf` files, drop them in
  `assets/fonts/`, declare them in `pubspec.yaml`, and swap the `GoogleFonts`
  calls in `lib/theme/app_theme.dart` for the bundled family.
- **Images:** onboarding and service photos are loaded from the Unsplash CDN as
  mock content. If a device is offline or a URL fails, a themed placeholder is
  shown automatically (`lib/widgets/network_image_with_fallback.dart`). Swap the
  URLs in `lib/data/mock_data.dart` for your own assets anytime.

## Design tokens

- Background `#0E0E11`, surface `#1E1E24`
- Copper accent (logo) `#C6863E`
- Red accent (links / bottom bar) `#E5372B`
- Pill inputs & buttons, radius 30; cards radius 22

## Next up

Send the **Order Food** design set and I'll replace the placeholder with the
full flow (menu, item detail, cart, checkout, etc.), reusing the theme and
widgets already in place.
