# Carlog 🚗

A comprehensive vehicle maintenance tracking app built with Flutter. Track fuel costs, maintenance work, and parts purchases with smart OCR receipt scanning.

## Features

- **🔐 Authentication** — Email/password and Google Sign-In via Firebase Auth
- **📷 AI-Powered Receipt Parsing** — Leveraging Gemini 1.5 Flash to automatically detect receipt type (fuel, store, mechanic bill) and extract structured JSON data.
- **⛽ Refuel Logging** — Formerly "Magic Scan", log refueling with station name, liters, cost, and odometer captured via AI.
- **🔧 Maintenance Tracking** — Record repairs, services, and parts purchases with AI-assisted data entry.
- **📊 Reports** — Three-tab reports: Refueling history, Maintenance timeline, Parts & Tools purchased.
- **📱 Odometer Capture** — Take a photo of your odometer during refueling or from the expense form for automatic reading extraction.
- **🧾 Store Receipt Scanning** — Scan auto parts store receipts to create individual transaction entries.
- **📝 Mechanic Bill Scanning** — Scan mechanic bills with smart field detection and editable verification.
- **💰 Cost-per-KM** — Calculate and share your vehicle's cost per kilometer.
- **🔔 Real-time Settings** — Localization settings (Currency, Date Format) update instantly across the app.
- **🌙 Dark Theme** — Premium dark UI with #135BEC accent color and Inter font
- **📶 Offline-First** — Works offline with Hive local storage, syncs to Firestore when online

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | BLoC (flutter_bloc) |
| Authentication | Firebase Auth + Google Sign-In |
| Database (Remote) | Cloud Firestore |
| Database (Local) | Hive |
| OCR | Google ML Kit Text Recognition |
| AI Parsing | Gemini 1.5 Flash (google_generative_ai) |
| DI | GetIt + Injectable |
| Analytics | Firebase Analytics + Crashlytics |

## Architecture

Clean Architecture with three layers per feature:

```
lib/
├── core/                   # Shared services, theme, config
├── features/
│   ├── auth/               # Login, Signup, Forgot Password
│   ├── logs/               # Fuel & Maintenance logging
│   ├── vehicles/           # Vehicle management (Garage)
│   ├── reports/            # Reports with 3 tabs
│   └── settings/           # Profile, Notifications, Privacy, Help
├── injection.dart          # GetIt + Injectable setup
└── main.dart               # App entry point with AuthGate
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Firebase project with `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd carlog

# Install dependencies
flutter pub get

# Generate injectable config (if needed)
flutter pub run build_runner build --delete-conflicting-outputs
```
# Run the app (Pass your Gemini API Key)
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

### Firebase & AI Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password + Google)
3. Enable **Cloud Firestore**
4. Get a Gemini API Key from [Google AI Studio](https://aistudio.google.com/)
5. Download and place config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/services/receipt_parser_service_test.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
