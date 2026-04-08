# Architecture

## Overview

This project follows a **monorepo architecture** with two Flutter apps and a shared package.

```
wtf_flutter_test/
├── apps/
│   ├── guru_app/          # Member (DK) - Blue theme (#1769E0)
│   └── trainer_app/       # Trainer (Aarav) - Red theme (#E50914)
├── packages/
│   └── shared/            # Shared code between both apps
│       ├── lib/
│       │   ├── models/    # Data models with Hive adapters
│       │   ├── services/  # Business logic services (singletons)
│       │   ├── bloc/      # BLoC state management
│       │   ├── widgets/   # Reusable UI components
│       │   └── utils/     # Constants, theme, extensions, validators
│       └── test/          # Unit tests
└── token_server/          # Node.js 100ms token server
```

## Architecture Pattern

**Clean Architecture** with three layers:

1. **Data Layer** (`models/`) — Equatable data classes with Hive type adapters for local persistence.
2. **Domain Layer** (`services/`) — Singleton services encapsulating business logic. Each service owns a reactive stream (BehaviorSubject) for state broadcasting.
3. **Presentation Layer** (`bloc/`, `widgets/`, `screens/`) — BLoC pattern for state management. Widgets subscribe to BLoC state. Screens compose widgets.

## State Management

**BLoC (Business Logic Component)** using `flutter_bloc`.

```
UI Event → BLoC → Service → Storage → Stream → BLoC State → UI
```

Five BLoCs:
- `AuthBloc` — Login/logout, session management
- `ChatBloc` — Messages, typing indicators, chat rooms
- `ScheduleBloc` — Day/slot selection, schedule CRUD, approval flow
- `SessionBloc` — Session logs, filtering, rating, notes
- `CallBloc` — Video call lifecycle (join, controls, leave)

## Data Flow

### Chat System
```
User types → ChatBloc.SendMessage → ChatService.sendMessage()
  → StorageService (Hive) → BehaviorSubject stream
  → ChatBloc listens → UI updates

Status pipeline: sending → sent (200ms) → delivered (400ms) → read (on open)
```

### Scheduling
```
Guru selects slot → ScheduleBloc.Create → ScheduleService.createSchedule()
  → Validation (past time, conflicts, business hours)
  → StorageService (Hive)
  → System message added to chat
  → Trainer sees pending request → Approve/Decline
```

### Video Call
```
User taps Join → CallBloc.Join → HmsService.getAuthToken()
  → Token server (or mock fallback) → HMSSDK.join()
  → CallState stream updates → UI renders
  → On leave → SessionLog created
```

## Storage

**Hive** — NoSQL local database with type adapters:

| Box            | Type ID | Purpose              |
|----------------|---------|----------------------|
| users          | 0       | AppUser profiles     |
| messages       | 1       | Chat messages        |
| chatRooms      | 2       | Chat room metadata   |
| schedules      | 3       | Schedule requests    |
| sessionLogs    | 4       | Completed sessions   |
| settings       | —       | App preferences      |

## Service Layer

All services are **lazy singletons** (`ServiceName.instance`):
- `StorageService` — Hive box management, CRUD operations
- `AuthService` — Mock auth with predefined users
- `ChatService` — Message sending, delivery simulation, typing, auto-replies
- `ScheduleService` — Slot generation, validation, CRUD with chat integration
- `SessionService` — Session log creation, rating, notes, filtering
- `HmsService` — 100ms token fetching, call state management
- `LogService` — Structured logging with tag-based filtering

## Performance Targets

| Metric              | Target       |
|---------------------|-------------|
| Chat message latency | < 400ms     |
| RTC join time       | < 4 seconds  |
| UI animation        | 150–250ms    |
| Scrolling           | 60fps        |
