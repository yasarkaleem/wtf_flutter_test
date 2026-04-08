# Technical Decisions

## 1. Monorepo Structure
**Decision:** Single repo with `apps/` and `packages/` directories.
**Why:** Both apps share 80%+ of code (models, services, BLoCs, widgets). A monorepo with a shared Dart package avoids duplication and ensures type safety across apps.
**Trade-off:** Slightly more complex build setup, but massively reduced maintenance.

## 2. BLoC for State Management
**Decision:** flutter_bloc over Riverpod.
**Why:** BLoC enforces a strict unidirectional data flow (Event → BLoC → State) which is ideal for this app's complexity level. The event-driven pattern makes debugging easier (every state change has a traceable event). BLoC also integrates well with streams from the service layer.

## 3. Hive for Local Storage
**Decision:** Hive over SQLite/drift.
**Why:** Hive is faster for simple key-value operations, requires no native dependencies for basic use, and has a simpler API for the data structures in this project. The data model is flat (no complex joins needed), making a NoSQL approach more natural.

## 4. Stream-Based Chat Simulation
**Decision:** RxDart BehaviorSubjects for real-time feel instead of WebSockets.
**Why:** For local-first operation without a backend, streams provide the same reactive UX. BehaviorSubject ensures new subscribers immediately get the latest state. The architecture is backend-ready — swap the stream source from local to WebSocket with minimal changes.

## 5. Singleton Services
**Decision:** Lazy singleton pattern for all services.
**Why:** Services manage shared state (current user, active call) that must be consistent across both BLoCs and UI. Singletons ensure a single source of truth. The pattern is simple and avoids dependency injection overhead for this project scale.

## 6. Mock Authentication
**Decision:** Hardcoded users (DK as Guru, Aarav as Trainer) with instant login.
**Why:** The project focuses on demonstrating real-time features, not auth flows. Mock auth removes the need for a backend while still exercising the full user lifecycle.

## 7. 100ms with Mock Fallback
**Decision:** Real 100ms SDK integration with automatic mock token fallback.
**Why:** The architecture supports real 100ms video calls when credentials are configured, but gracefully falls back to simulated calls when the token server is unavailable. This allows the app to run locally without any external dependencies.

## 8. Auto-Reply Simulation
**Decision:** Automatic simulated replies from the other user after each message.
**Why:** Since both apps run independently with local storage, there's no real cross-app communication. Auto-replies demonstrate the typing indicator, read receipts, and message delivery pipeline in a single app instance.

## 9. System Messages in Chat
**Decision:** Schedule events (created, approved, declined) generate system messages in the chat.
**Why:** Keeps users informed of scheduling activity within their conversation context. This is a common pattern in messaging apps (WhatsApp, Slack) and provides an audit trail.

## 10. 8pt Spacing Grid
**Decision:** All spacing uses multiples of 8px.
**Why:** 8pt grid system ensures visual consistency, aligns with Material Design guidelines, and makes spacing decisions predictable. Defined as constants in `AppTheme` for consistency.

## 11. Structured Logging with Tags
**Decision:** Tagged logging system ([CHAT], [RTC], [SCHEDULE], etc.) with a DevPanel widget.
**Why:** Makes debugging specific subsystems easy. The DevPanel provides in-app log viewing with tag filtering, which is critical for development without a connected debugger.

## 12. Pre-Generated Hive Adapters
**Decision:** Hand-written `.g.dart` files instead of using build_runner.
**Why:** Eliminates the build_runner step for initial setup, making the project immediately runnable. The adapters follow the exact same pattern that build_runner would generate. For production, switch to generated adapters.
