# Damas Dash

> A polished, production-ready Flutter admin dashboard with bilingual support, animated splash experience, and a cohesive green-accented design system.

---

## Overview

Damas Dash is a Flutter-based business intelligence dashboard application designed for monitoring key performance metrics. It provides a multi-screen interface covering revenue summaries, analytics overviews, report management, and application settings — all wrapped in a consistent, brand-driven UI built on a centralized design system.

The app launches with a fully animated splash screen, then routes to a persistent shell (app bar + slide-out drawer) that hosts four main sections via an `IndexedStack`.

---

## Features

- **Animated Splash Screen** — Multi-stage entrance animation with five concurrent `AnimationController`s handling background sweep, logo scale/glow/ring effects, staggered content reveal, and a progress bar; transitions into the home shell via a custom `PageRouteBuilder` fade.
- **Dashboard Overview** — KPI stat cards (Net Revenue, Subscriptions, Churn Rate, Active Users) rendered in a 2-column `GridView`, an interactive line chart powered by `fl_chart`, and a recent activity feed.
- **Analytics Screen** — Performance overview section with responsive stat cards (switches from `Row` to `Column` layout below 600px), a performance chart placeholder container, and a recent activity list.
- **Reports Screen** — Recent reports list with per-item status (ready vs. generating), download action per report, quick action buttons (Generate Report, Export CSV), and a scheduled automated reports section.
- **Settings Screen** — Grouped settings layout (Account, Preferences, System) with `SettingsTile` for navigable items and `SwitchListTile.adaptive` toggles for Dark Mode and Notifications; constrained to 800px max-width for desktop readability.
- **Notification Panel** — Overlay popup (`showGeneralDialog`) anchored to the app bar with a scale+fade transition, listing timestamped notification items.
- **Slide-Out Drawer Navigation** — 260px green-themed sidebar with avatar header, `MENU` section label, animated selected-state highlighting on each `SideBarItem`, and integrated page switching via `IndexedStack`.
- **Bilingual Typography** — `AppFonts` utility resolves to `Oswald` for English locales and `Almarai` for Arabic, with locale-aware `letterSpacing` and `lineHeight` tuning. The splash screen renders Arabic subtitle text with correct `TextDirection.rtl`.
- **Centralized Design System** — `AppColors` defines the full green palette: surface layers, primary accents, gradients (background, primary, card, glow), border tokens, and text hierarchy colors.
- **Glassmorphism App Bar** — `BackdropFilter` blur applied to the app bar for a frosted-glass SaaS aesthetic.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | `StatefulWidget` + `setState` (local), `IndexedStack` for page persistence |
| Animation | `AnimationController`, `Tween`, `CurvedAnimation`, `TickerProviderStateMixin` |
| Charting | `fl_chart` |
| Typography | Oswald (English), Almarai (Arabic), RobotoCondensed (fallback) |
| Navigation | Named routes + `Navigator.pushReplacement` + `PageRouteBuilder` |
| Rendering | `CustomPaint` (arc and grid painters on splash) |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point — calls runApp(Main())
├── app.dart                         # MaterialApp: theme, initial route, route table
│
├── core/
│   ├── app_colors.dart              # Complete color palette + gradient definitions
│   └── app_fonts.dart               # Font resolution by locale + TextStyle factory
│
├── dashboard/                       # Dashboard feature module
│   ├── screens/
│   │   └── dashboard_screen.dart    # KPI grid, chart, activity feed composition
│   └── widgets/
│       ├── dashboard_header.dart    # Page title + subtitle
│       ├── stat_card.dart           # Metric card with icon, value, trend badge
│       ├── analytics_chart.dart     # fl_chart LineChart wrapper
│       ├── activity_section.dart    # Recent activity container
│       └── activity_tile.dart       # Individual activity row
│
├── screens/
│   ├── home_screen.dart             # Shell: Scaffold + Drawer + AppBar + IndexedStack
│   ├── analytics_screen.dart        # Analytics page (self-contained with private widgets)
│   ├── reports_screen.dart          # Reports page (self-contained with private widgets)
│   └── splash/
│       ├── splash_screen.dart       # Stateful splash orchestrator + part directive
│       └── splash_animation.dart    # part of splash_screen — all animation sub-widgets
│   └── settings/
│       ├── screens/
│       │   └── settings_screen.dart # Settings page layout
│       └── widgets/
│           ├── settings_group.dart  # Section container with uppercase label
│           ├── settings_tile.dart   # Navigable list row
│           ├── settings_toggle.dart # SwitchListTile.adaptive with branded styling
│           └── settings_footer.dart # Save / Discard action buttons
│
└── widgets/                         # Shared, app-wide widgets
    ├── app_bar.dart                 # Glassmorphism AppBar with notification trigger
    ├── side_bar.dart                # Drawer: avatar header + navigation items
    ├── side_bar_items.dart          # Animated SideBarItem with selection state
    └── windows/
        └── notification_window.dart # Overlay notification panel
```

---

## Architecture

The project does not implement a formal layered architecture such as Clean Architecture or BLoC. Instead, it follows a **feature-first widget decomposition** pattern with a shared `core/` module:

- **`core/`** acts as a global design token layer. `AppColors` and `AppFonts` are pure utility classes (private constructors / static members only) — no instantiation, no state. All screens consume them directly, ensuring visual consistency without a theming provider.
- **Feature modules** (`dashboard/`, `screens/settings/`) own both their screen-level composition widget and their constituent sub-widgets. Private widget classes (prefixed with `_`) are co-located inside screen files where they have a single consumer (e.g., `_HeaderSection`, `_StatsGrid` in `analytics_screen.dart`), and promoted to separate files when reused across screens (e.g., `StatCard`, `ActivitySection`).
- **Navigation** is handled by named routes declared in `app.dart`. The home shell uses `IndexedStack` to preserve widget state across tab switches without rebuilding pages on each visit.
- **Animation** is self-contained inside `SplashScreen` using `TickerProviderStateMixin`. The `part` / `part of` directive splits the file into logical rendering units (`splash_animation.dart`) while keeping them within the same Dart library scope.

This approach is appropriate for a UI-focused dashboard at this scale and keeps the cognitive overhead low.

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.x
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code with Flutter plugin, or any terminal with `flutter` on PATH

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/damas-dash.git
cd damas-dash

# Install dependencies
flutter pub get
```

### Dependencies

Ensure `pubspec.yaml` includes the following (verify exact versions in the file):

```yaml
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^x.x.x       # Line chart rendering on the dashboard
```

Font assets (`Oswald`, `Almarai`, `RobotoCondensed`) must be declared under `flutter.fonts` in `pubspec.yaml` and placed in the `assets/fonts/` directory.

---

## Usage

```bash
# Run on a connected device or emulator
flutter run

# Build release APK
flutter build apk --release

# Build for iOS
flutter build ipa
```

The app launches into the animated splash screen and automatically navigates to the home shell after ~3 seconds.

---

## Screens & UI

### Splash Screen
Full-screen dark green gradient with five sequenced animations: background radial glow, rotating arc decoration (via `CustomPaint`), logo tile with concentric ring pulse and glow halo, staggered title/subtitle/tagline fade-in with slide offsets, and a progress bar that animates from 0–100% before the transition fires.

### Dashboard (Home)
Light background (`#F8FAF9`) with a 2×2 KPI grid showing Net Revenue, Subscriptions, Churn Rate, and Active Users — each card carrying a trend badge colored green (positive) or red (negative). Below the grid sits a `fl_chart` line chart and a recent activity list of payment/order tiles.

### Analytics
Responsive stat grid (3 cards: Total Users, Revenue, Growth) that collapses from a `Row` to a `Column` on viewports below 600px. Includes a performance chart placeholder section and a recent activity feed with timestamped items.

### Reports
Two quick-action buttons (Generate Report, Export CSV), a recent reports list with file metadata and per-item download buttons, and a scheduled reports section showing recurring report configurations with recipient email.

### Settings
Grouped into Account (Profile, Security), Preferences (Dark Mode toggle, Notifications toggle), and System (About, Help & Support). Max-width constrained at 800px. Footer provides Save Changes and Discard Changes actions.

### Notification Panel
Dropdown overlay triggered from the app bar bell icon. Renders with a combined scale+fade `transitionBuilder`, anchored top-center, listing three notification items with timestamps.

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `fl_chart` | Line chart visualization on the dashboard screen |
| `flutter` (SDK) | Core framework, widgets, animation, and rendering |

> Font packages (Oswald, Almarai, RobotoCondensed) are loaded as local asset fonts, not pub packages.

---

## Code Quality Notes

- `AppColors` and `AppFonts` are well-designed as sealed utility classes — private constructors prevent misuse, and the locale-aware `getTextStyle()` factory in `AppFonts` is a production-grade pattern.
- The `SettingsToggle` component is correctly decoupled via `ValueChanged<bool>` — it holds no internal state, making it trivially integrable with any state management solution.
- `SideBarItem` uses `AnimatedContainer` for smooth selection transitions, which is preferable to abrupt color swaps.
- The splash screen correctly disposes all five `AnimationController`s in `dispose()`, preventing common memory leaks associated with `TickerProviderStateMixin`.
- The `part` / `part of` split in the splash module is a clean approach to managing file length without introducing unnecessary separate libraries.
- Toggle callbacks in `SettingsScreen` (`onChanged`) are stubs — wired to the UI structure but not yet connected to any state management layer.
- `ActivityTile` is currently rendered with a hardcoded `index: 0` in the `List.generate` call inside `ActivitySection`, which prevents dynamic data from flowing through correctly.

---

## Future Improvements

Based on the code structure, the following extensions are natural next steps:

- **State Management Integration** — The settings toggles and sidebar selection state are architected to accept external state. Integrating `Provider`, `Riverpod`, or `Bloc` would complete the wiring without requiring widget restructuring.
- **Dark Mode** — `AppColors` already defines a full dark-surface palette (`surfaceDark`, `surfaceLight`, `card`, `cardElevated`). Connecting the existing Dark Mode toggle to a `ThemeMode` provider would be straightforward.
- **Dynamic Data Layer** — All KPI values, chart data points, activity items, and report lists are currently hardcoded. The widget APIs are already parameterized and ready for a repository/service layer.
- **Chart Axes & Interactivity** — The `fl_chart` instance has `titlesData` and axis labels disabled. Enabling touch interaction and labeled axes would complete the analytics experience.
- **Localization** — `AppFonts` already resolves by `Locale`. Full `flutter_localizations` + ARB file integration would complete the bilingual (Arabic/English) support indicated by the font system.