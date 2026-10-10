# 📱 Bill Collector & Tracker App (جامع الفواتير)

A modern, feature-packed Flutter mobile application designed for tracking, managing, and calculating monthly and daily bills with receipt photo attachments, multi-currency support, and full bilingual localization (English & Arabic RTL).

---

## 🌟 Key Features

- 📊 **Daily & Monthly Calculations**: Real-time spending progress header calculating total bills due, paid amounts, and remaining balances.
- 📸 **Receipt & Bill Photo Capture**: Attach photos directly from the **Camera** or **Mobile Gallery** with an integrated full-screen receipt viewer.
- 🌐 **Bilingual Localization (English / العربية)**: Instant toggling between English (LTR) and Arabic (RTL) across the entire UI.
- 💱 **Multi-Currency Support**: Supports 7 popular currencies: **USD ($)**, **EGP (EGP)**, **SAR (ر.س)**, **EUR (€)**, **GBP (£)**, **AED (د.إ)**, **IQD (د.ع)**.
- 💾 **Permanent On-Device Persistence**: Local storage using `shared_preferences` keeps all bills, statuses, images, and preferences saved securely across app restarts.
- 🔄 **Recurring Bills Import**: One-tap tool to automatically import recurring bills from previous months.
- 🎨 **Material 3 Design**: Fully responsive UI styled with dynamic themes and smooth sheet modals.

---

## 🛠 Tech Stack & Dependencies

| Layer | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart SDK 3.x) |
| **Design System** | Material Design 3 |
| **Local Storage** | `shared_preferences` |
| **Media Handling** | `image_picker` (Camera & Mobile Gallery) |
| **Localization** | Custom RTL / LTR `Directionality` & Locale Manager |

---

## 📁 Project Architecture

```text
lib/
├── main.dart                    # App entry point & Material Theme configuration
├── models/
│   ├── bill.dart                # Bill data model & category/status enums
│   └── app_settings.dart        # Currency & Language preferences state
├── screens/
│   ├── home_screen.dart         # Main Dashboard & calculation logic
│   └── welcome_screen.dart      # Onboarding welcome screen
└── widgets/
    ├── add_edit_bill_sheet.dart # Modal sheet to add/edit bills & attach photos
    ├── bill_card.dart           # Expandable bill card with actions & image viewer
    ├── settings_sheet.dart      # Currency & Language selection bottom sheet
    └── summary_header.dart      # Daily / Monthly calculation banner
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.0.0 or higher)
- Android Studio / VS Code
- Android Device or Emulator (Android 5.0 / API 21+)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mhmdjoe/BillCollector.git
   cd BillCollector
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

4. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```
   *The generated APK file will be saved at `build/app/outputs/flutter-apk/BillCollector.apk`.*

---

## 📄 License
This project is open source and available under the [MIT License](LICENSE).
