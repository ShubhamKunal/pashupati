# PASHUPATI — Developer Guidelines & Workflows

## 1. Code Standards

### Flutter / Dart
- **Formatting**: Run `dart format lib test` before every commit.
- **Analysis**: Run `flutter analyze` — code must pass with zero issues.
- **State Management**: Use Riverpod `StateNotifierProvider`. Never invoke `setState()` across multiple widgets for global domain models.
- **Immutability**: All model classes must have immutable `final` properties and implement `copyWith` and `toJson()`.
- **Design Tokens**: Never hardcode colors directly in UI widgets. Always use `PashupatiColors` or `Theme.of(context).colorScheme`.

### Rust Backend
- **Formatting**: Run `cargo fmt --check`.
- **Clippy**: Run `cargo clippy -- -D warnings`.
- **Errors**: Handlers must return `Result<Json<T>, AppError>` using typed `AppError` variants.
- **Logging**: Use `tracing::info!`, `tracing::warn!`, `tracing::error!`. Never log credentials, OTPs, or exact private coordinates.

---

## 2. Testing Strategy

### Running Flutter Tests
```bash
flutter test
```
Tests cover:
- Domain model JSON serialization & deserialization (`test/unit/sos_model_test.dart`).
- Distance formatting logic for meters vs kilometers.
- Splash screen branding and animations (`test/widget_test.dart`).
- Home screen emergency dispatch trigger & live feed (`test/widget/home_screen_test.dart`).
- SOS Creation 3-step triage workflow (`test/widget/sos_creation_test.dart`).

---

## 3. Database Migrations Workflow

New migrations must be added to `backend/migrations/` using timestamped naming:
```text
YYYYMMDDHHMMSS_action_name.sql
```
Migrations are automatically applied on startup via SQLx:
```rust
sqlx::migrate!("./migrations").run(&pool).await?;
```
To run migrations manually using the SQLx CLI:
```bash
cargo install sqlx-cli --no-default-features --features postgres
sqlx migrate run --source backend/migrations
```

