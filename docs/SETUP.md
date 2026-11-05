# PASHUPATI — Local Developer Setup Guide

## 1. Prerequisites
Ensure you have the following installed on your machine:
- **Flutter SDK**: 3.47+ (Dart 3.13+)
- **Docker Desktop** (or Docker Engine 24+)
- **Rust Toolchain**: 1.80+ (optional if running backend inside Docker)

---

## 2. Clone and Setup Environment

```bash
git clone https://github.com/pashupati/pashupati.git
cd pashupati
cp .env.example .env
```

---

## 3. Launch PostgreSQL + PostGIS Infrastructure

Start the PostgreSQL 16 container with PostGIS 3.4 and MinIO object storage:
```bash
docker compose up -d db minio
```

To verify the database container is healthy:
```bash
docker ps
```

---

## 4. Run Backend Server

### Option A: Via Docker Compose (Recommended)
```bash
docker compose up -d backend
```

### Option B: Native Cargo Run
```bash
cd backend
cp .env.example .env
cargo run
```
The backend will automatically execute all 6 database migrations on startup and seed initial Bengaluru rescue organizations, users, and cases.

Verify health check:
```bash
curl http://localhost:8080/health
```
Expected response:
```json
{
  "app": "Pashupati",
  "service": "pashupati-backend",
  "status": "healthy",
  "tagline": "Be the reason a life survives.",
  "version": "1.0.0"
}
```

---

## 5. Launch Flutter Mobile Client

```bash
flutter pub get
flutter run
```

### Android Emulator Networking Note:
Android emulators access the host machine's `localhost` via the special IP `10.0.2.2`. This is pre-configured in `lib/app/config/config.dart`.

