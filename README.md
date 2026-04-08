# Guru-Trainer Chat & Video Call System

Two Flutter apps for a coaching platform: **Guru App** (member) and **Trainer App** (trainer), with real-time chat, call scheduling, 100ms video calls, and session logs.

## Quick Start

### Prerequisites
- Flutter SDK >= 3.16.0
- Node.js >= 18 (for token server)

### 1. Install dependencies

```bash
# Shared package
cd packages/shared && flutter pub get && cd ../..

# Guru App
cd apps/guru_app && flutter pub get && cd ../..

# Trainer App
cd apps/trainer_app && flutter pub get && cd ../..
```

### 2. Run the apps

```bash
# Terminal 1: Guru App
cd apps/guru_app && flutter run

# Terminal 2: Trainer App
cd apps/trainer_app && flutter run
```

### 3. Token Server (optional, for real 100ms calls)

```bash
cd token_server
cp .env.example .env  # Add your 100ms credentials
npm install
npm start
```

## Project Structure

```
├── apps/
│   ├── guru_app/        # Member app (DK) - Blue theme
│   └── trainer_app/     # Trainer app (Aarav) - Red theme
├── packages/shared/     # Shared models, services, BLoCs, widgets
├── token_server/        # 100ms JWT token server
├── ARCHITECTURE.md      # System architecture details
├── DECISIONS.md         # Technical decision rationale
└── AI_LEDGER.md         # AI development tracking
```

## Features

| Feature | Status |
|---------|--------|
| Mock authentication | Done |
| Real-time chat (streams) | Done |
| Message status (sending/sent/delivered/read) | Done |
| Typing indicator | Done |
| Quick reply chips | Done |
| Schedule with calendar | Done |
| Time slot validation | Done |
| Trainer approve/decline | Done |
| 100ms video call integration | Done |
| Pre-join preview | Done |
| Call controls (mute/video/flip/end) | Done |
| Session logs with rating & notes | Done |
| Session filtering | Done |
| DevPanel with structured logs | Done |
| Loading skeletons | Done |
| Empty states | Done |

## Running Tests

```bash
cd packages/shared
flutter test
```

## Tech Stack

- **Flutter** 3.16+ with Dart 3.2+
- **State Management:** flutter_bloc
- **Local DB:** Hive
- **Video:** 100ms SDK (hmssdk_flutter)
- **Reactive:** RxDart
- **Token Server:** Express.js + jsonwebtoken
