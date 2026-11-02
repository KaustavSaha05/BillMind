# 💳 BillMind - Smart Bill Reminder & Management System

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%3E%3D3.0.0-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/SQLite-sqflite%202.3.0-003B57?logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Provider-State%20Management-22C55E" alt="Provider" />
  <br />
  <img src="https://img.shields.io/badge/Material%20Design-3.0-6366F1?logo=materialdesign&logoColor=white" alt="Material 3" />
  <img src="https://img.shields.io/badge/License-MIT-84CC16" alt="License MIT" />
</p>

<p align="center">
  <b>A modern, user-friendly mobile application for personal financial tracking, scheduled due date reminders, intelligent bill categorization, and automated recurring payment management powered by Flutter and SQLite.</b>
</p>

---

## 📌 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [App Architecture](#app-architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Setup](#environment-setup)
- [Usage](#usage)
  - [1. Interactive Bill Dashboard](#1-interactive-bill-dashboard)
  - [2. Adding & Managing Bills](#2-adding--managing-bills)
  - [3. Payment Tracking & Recurring Cycles](#3-payment-tracking--recurring-cycles)
  - [4. Automated Reminders & Notifications](#4-automated-reminders--notifications)
- [How It Works](#how-it-works)
- [Data Model](#data-model)
- [Configuration & Permissions](#configuration--permissions)
- [Testing](#testing)
- [Platform Support](#platform-support)
- [Privacy & Security](#privacy--security)
- [Contributing](#contributing)
- [License](#license)
- [Team & Acknowledgments](#team--acknowledgments)

---

## Overview

**BillMind** is a streamlined, client-side personal finance utility engineered to ensure users never incur late fees or miss an important payment deadline. Built using **Flutter** and **Material Design 3**, the application delivers a frictionless mobile experience to organize expenses, view upcoming obligations at a glance, and receive automated notifications before payments become due.

The app adopts an **offline-first** paradigm: all records, dates, and payment states are persisted locally in a structured **SQLite database** on the user's device, requiring zero cloud synchronization and offering complete privacy by design.

---

## Key Features

- **Interactive Financial Dashboard**: Instant visual summary cards highlighting total unpaid balances, overdue alerts, and tabbed categorization between upcoming and settled payments.
- **Multi-Stage Due Date Alerts**: Automated background notifications scheduled 7 days, 3 days, and 1 day prior to payment deadlines via `flutter_local_notifications`.
- **Payment Lifecycle Management**: Single-tap toggle to mark bills as paid or unpaid, recording exact completion timestamps.
- **Intelligent Recurring Bills**: Automatic next-cycle bill generation upon payment completion for recurring obligations (rent, subscriptions, utilities).
- **Categorization & Filtering**: Predefined categories (Utilities, Rent, Insurance, Subscriptions, Phone & Internet, Transportation, Entertainment, Healthcare, Education, Other) with distinct visual badge accents and icons.
- **Search & Quick Retrieval**: Real-time search query filtering across upcoming, paid, and overdue bills by name or category.
- **100% Offline & Private**: Zero external network requests or server transmission. All user data stays strictly on the local device.

---

## App Architecture

BillMind follows a clean, reactive architecture separating presentation, application state, data persistence, and system notification services.

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│    (HomeScreen, AddBillScreen, BillCard, StatisticsCard)    │
└──────────────────────────────▲──────────────────────────────┘
                               │ Observes state / Dispatches actions
┌──────────────────────────────▼──────────────────────────────┐
│                   State Management Layer                    │
│            BillProvider (ChangeNotifier Pattern)            │
└──────────────────▲───────────────────────▲──────────────────┘
                   │                       │
     Calls CRUD & Aggregations   Schedules / Cancels Alarms
                   │                       │
┌──────────────────▼──────────┐ ┌──────────▼──────────────────┐
│       DatabaseService       │ │     NotificationService     │
│   (SQLite / sqflite Engine) │ │(flutter_local_notifications)│
└─────────────────────────────┘ └─────────────────────────────┘
```

- **Presentation Layer**: Built with Flutter widgets using Material 3 styling, responsive tabs, and dynamic color-coded urgency indicators.
- **State Layer (`BillProvider`)**: Centralized state management maintaining active bill lists, filtered tabs, and computed aggregate totals (unpaid amounts, overdue counts).
- **Service Layer**:
  - `DatabaseService`: Handles database initialization, table creation, CRUD operations, and analytical queries.
  - `NotificationService`: Manages initialization with platform channels and schedules precise timezone-aware alarms.
- **Model Layer (`Bill`)**: Immutable domain entity supporting serialization (`toMap` / `fromMap`), status logic (`isOverdue`, `isDueSoon`, `daysUntilDue`), and copy mutations (`copyWith`).

---

## Tech Stack

| Component | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Framework** | Flutter | `>= 3.0.0` | Cross-platform UI toolkit |
| **Language** | Dart | `>= 3.0.0 < 4.0.0` | Core programming language |
| **Local Database** | `sqflite` | `^2.3.0` | Embedded SQLite relational database engine |
| **Filesystem Path** | `path` | `^1.8.3` | Cross-platform file path resolution |
| **State Management** | `provider` | `^6.1.1` | Reactive ChangeNotifier state management |
| **Notifications** | `flutter_local_notifications` | `^16.3.0` | Native background and scheduled alerts |
| **Date & Timezone** | `timezone` & `intl` | `^0.9.4` / `^0.18.1` | Timezone-aware date calculations & formatting |
| **Preferences** | `shared_preferences` | `^2.2.2` | Persistent key-value storage for settings |
| **Design System** | Material Design 3 | — | Modern Android/iOS typography, elevation & styling |

---

## Project Structure

```
BILLMIND-main/
├── android/                         # Android platform configuration & manifests
├── lib/                             # Core Flutter source code
│   ├── main.dart                    # Application entry point & theme definition
│   ├── models/
│   │   └── bill.dart                # Bill data model & status helpers
│   ├── providers/
│   │   └── bill_provider.dart       # State management & reactive business logic
│   ├── screens/
│   │   ├── home_screen.dart         # Main dashboard with statistics, tabs & search
│   │   └── add_bill_screen.dart     # Form screen for creating & editing bills
│   ├── services/
│   │   ├── database_service.dart    # SQLite database helpers & CRUD queries
│   │   └── notification_service.dart# Scheduled notifications & alarm manager
│   └── widgets/
│       ├── bill_card.dart           # Interactive bill tile with status & actions
│       ├── empty_state.dart         # Reusable empty list placeholder widget
│       └── statistics_card.dart     # Dashboard metrics & count overview cards
├── test/
│   └── widget_test.dart             # UI and widget regression tests
├── pubspec.yaml                     # Project dependencies & metadata
└── README.md                        # Documentation
```

---

## Getting Started

### Prerequisites

Ensure you have the following installed on your development workstation:
- **Flutter SDK**: `3.0.0` or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Bundled with Flutter
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Android Device** or **Emulator**: Running Android API level 21 or higher

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/BILLMIND.git
   cd BILLMIND-main
   ```

2. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter environment:**
   ```bash
   flutter doctor
   ```

### Environment Setup

Connect a physical Android device via USB debugging or start an Android Virtual Device (AVD).

1. **Run in development mode:**
   ```bash
   flutter run
   ```

2. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```

3. **Build Android App Bundle (AAB for Google Play):**
   ```bash
   flutter build appbundle --release
   ```

---

## Usage

### 1. Interactive Bill Dashboard
The home screen serves as an active control center:
- **Financial Cards**: Displays the total unpaid balance and overdue alert count.
- **Status Tabs**: Segregates bills into **Upcoming** and **Paid** views.
- **Search Bar**: Real-time filtering by bill name or category.
- **Status Pills**: Color-coded badges indicating *Overdue*, *Due Soon* (within 3 days), or *Due in X days*.

### 2. Adding & Managing Bills
1. Tap the floating **`+` Action Button** on the dashboard.
2. Provide the bill title, monetary amount, and due date.
3. Select an appropriate category (e.g., *Utilities*, *Rent*, *Subscriptions*).
4. Toggle whether the bill is **Recurring** (monthly cycle).
5. Tap **Save Bill** to persist to SQLite and register notifications.

### 3. Payment Tracking & Recurring Cycles
- **Mark as Paid**: Tap the status checkbox on any bill card to mark it paid. The paid timestamp is recorded, and the item shifts to the **Paid** tab.
- **Automatic Rollover**: If the bill is marked as `isRecurring`, paying it automatically creates and schedules the bill for the subsequent month.
- **Reopen Payments**: Easily unmark a paid bill if recorded by mistake.

### 4. Automated Reminders & Notifications
- Reminders are automatically registered using `flutter_local_notifications` and zoned timezone calculations.
- Notifications trigger at **7 days**, **3 days**, and **1 day** before the due date.
- Paying or deleting a bill immediately cancels any pending reminder alarms.

---

## How It Works

```
[ User Input ] ──► [ AddBillScreen ] ──► [ BillProvider.addBill() ]
                                                  │
                      ┌───────────────────────────┴───────────────────────────┐
                      ▼                                                       ▼
            [ DatabaseService ]                                     [ NotificationService ]
             Inserts into SQLite                                   Schedules Alarms (7d, 3d, 1d)
                      │                                                       │
                      ▼                                                       ▼
            Persisted on Device                                     System Tray Reminder Alert
                      │
                      ▼
            [ HomeScreen / UI ]
            Re-renders via ChangeNotifier
```

1. **Submission**: User enters bill attributes in `AddBillScreen`.
2. **State Dispatch**: `BillProvider` coordinates with `DatabaseService` to insert the new record.
3. **Alarm Registration**: `NotificationService` checks remaining days and sets exact alarms using Android notification channels.
4. **Reactive Render**: `ChangeNotifier` triggers listeners across the app, updating metrics in `StatisticsCard` and bill lists in `HomeScreen`.
5. **Lifecycle Actions**: Updates or status toggles refresh both SQLite rows and active notification schedules synchronously.

---

## Data Model

The `Bill` entity defines the core schema:

```dart
class Bill {
  final int? id;             // Auto-incremented primary key
  final String name;          // Bill title (e.g., Electricity)
  final double amount;        // Bill amount due
  final DateTime dueDate;     // Due date and time
  final String category;      // Category label
  final bool isPaid;          // Payment status (0 = unpaid, 1 = paid)
  final bool isRecurring;     // Monthly recurrence flag
  final DateTime? paidDate;   // Timestamp when payment was completed
  final DateTime createdAt;  // Record creation timestamp
}
```

### Computed Properties
- `isOverdue`: Returns `true` if `!isPaid && dueDate < now`.
- `isDueSoon`: Returns `true` if `!isPaid` and due within the next 3 days.
- `daysUntilDue`: Returns integer days remaining until `dueDate`.

---

## Configuration & Permissions

The application requires the following Android permissions declared in `android/app/src/main/AndroidManifest.xml`:

| Permission | Reason |
| :--- | :--- |
| `android.permission.VIBRATE` | Enables tactile feedback when bill reminders fire |
| `android.permission.RECEIVE_BOOT_COMPLETED` | Re-registers scheduled alarms after device restarts |
| `android.permission.SCHEDULE_EXACT_ALARM` | Ensures timely delivery of exact deadline alerts |

---

## Testing

BillMind includes tests verifying widget creation, state behavior, and data structures.

Run the test suite with:

```bash
flutter test
```

---

## Platform Support

| Platform | Support Status | Notes |
| :--- | :---: | :--- |
| **Android** | Supported (Target) | Full support (API 21+), exact alarms & local notifications |
| **iOS** | Compatible | Core logic supported via Darwin notifications |
| **Web / Desktop** | Experimental | Basic UI functional; local notification plugin requires platform adapters |

---

## Privacy & Security

- **Zero Cloud Storage**: All records are maintained purely on device inside the local SQLite database.
- **No Analytics / Telemetry**: No tracking identifiers, telemetry beacons, or external network requests are executed.
- **Full User Control**: Deleting a bill completely purges the associated record and scheduled system alarms.

---

## Contributing

1. Fork the Project repository.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## License

This project is licensed under the **MIT License**.

---

## Team & Acknowledgments

### Core Team
- **Kaustav Saha** — *Team Lead, Backend Developer*
- **Aritra Chowdhury** — *Frontend Developer*

### Project Mentors
- **Prof. Subhabrata Sengupta** — *Project Mentor*
- **Prof. Dr. Rupayan Das** — *Project Mentor*

### Acknowledgments
- Flutter & Dart open source communities
- Material Design 3 guidelines and assets
