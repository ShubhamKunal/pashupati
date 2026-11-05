# PASHUPATI (पशुपति)
> **Be the reason a life survives.**

Production-grade, community-powered animal rescue and emergency triage mobile platform.

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter)](https://flutter.dev)
[![Rust](https://img.shields.io/badge/Rust-1.80+-000000?logo=rust)](https://www.rust-lang.org)
[![PostgreSQL + PostGIS](https://img.shields.io/badge/PostGIS-16--3.4-336791?logo=postgresql)](https://postgis.net)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🐾 Product Overview

Pashupati connects everyday citizens who encounter animals in distress with nearby volunteers, certified first responders, NGOs, animal shelters, and 24/7 veterinary hospitals.

The platform facilitates rapid real-world triage, GPS-accurate SOS broadcasting, synchronized response coordination, duplicate detection, and post-rescue outcome verification.

### Core Capabilities:
1. **1-Tap Emergency SOS Trigger**: Giant tactile trigger button with press-and-hold haptic dispatch.
2. **Sub-30s Pinpoint GPS Lockdown**: Automatic high-accuracy coordinates (`±5m`) with reverse-geocoded landmarks and offline draft fallback.
3. **Smart PostGIS Dispatch Radar**: Finds verified responders using indexed geospatial queries (`ST_DWithin`) within configurable radii (3km / 5km / 10km).
4. **Duplicate SOS Guard**: Spatial-temporal proximity algorithm preventing duplicate incident reports.
5. **Real-time Live Telematics**: Duplex WebSockets streaming live responder bike/vehicle telemetry, ETA countdowns, and case milestone steppers.
6. **24/7 Animal Care Directory**: Verified emergency trauma centers, veterinary ambulances, and NGO shelters with 1-tap emergency calling (`tel:`).
7. **Responder Concurrency Lock**: Row-level database locks (`SELECT FOR UPDATE`) eliminating race conditions when claiming primary responses.

---

## 🏛️ System Architecture

```text
pashupati/
├── assets/
│   ├── branding/           # Vector & adaptive app icons (logo.svg, ic_launcher)
│   └── mock/               # Offline seed telemetry
├── backend/
│   ├── Cargo.toml          # Rust Axum modular monolith
│   ├── Dockerfile          # Multi-stage production container
│   ├── migrations/         # 6 PostGIS SQL migrations & Bengaluru seed data
│   └── src/
│       ├── main.rs         # Application entrypoint & background workers
│       ├── auth/           # Phone OTP & JWT session manager
│       ├── database/       # SQLx connection pool & migration runner
│       ├── middleware/     # Auth, CORS, and rate limiting
│       ├── modules/        # Domain modules (sos, responders, orgs, users, activity)
│       └── websocket/      # Duplex telematics hub with room broadcasting
├── lib/                    # Flutter Mobile Application (Material 3 + Stitch Theme)
│   ├── app/                # App bootstrap, router, and design tokens
│   ├── core/               # Centralized Dio API client, Location, Storage, WS
│   ├── features/           # Feature-first modules (home, sos, tracking, explore, etc.)
│   └── shared/             # Strongly typed domain models
├── stitch_designs/         # Source of truth HTML/CSS/SVG screens from Stitch
└── test/                   # Comprehensive Flutter unit & widget test suite
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Flutter SDK**: 3.47+ (`Dart 3.13+`)
- **Rust Toolchain**: 1.80+ (optional for backend development)
- **Docker & Docker Compose**: 24+

### 2. Start PostgreSQL + PostGIS & Backend via Docker
```bash
docker compose up -d
```
The database with PostGIS extensions will initialize on `localhost:5432`, apply all 6 SQL migrations, seed realistic Bengaluru animal-care centers, and start the Rust API server on `http://localhost:8080`.

### 3. Run the Mobile Client
```bash
flutter pub get
flutter run
```
The Flutter app has built-in offline mock resilience: if the backend server is offline or unreachable, the client automatically defaults to verified local seed data with full interactive fidelity!

### 4. Run Tests
```bash
flutter test
```
All unit and widget tests will execute against mocked network layers.

---

## 📚 Technical Documentation Index

- [**ARCHITECTURE.md**](docs/ARCHITECTURE.md): System architecture, clean layers, concurrency models, and state management.
- [**DATABASE.md**](docs/DATABASE.md): PostGIS relational schema, spatial indexes, and migration dictionary.
- [**API.md**](docs/API.md): Versioned REST API documentation (`/api/v1/`) with DTOs and sample payloads.
- [**WEBSOCKET_EVENTS.md**](docs/WEBSOCKET_EVENTS.md): Live telematics protocol, subscriptions, and payloads.
- [**SECURITY.md**](docs/SECURITY.md): Privacy safeguards, phone masking, GPS fuzzing, and rate limiting.
- [**SETUP.md**](docs/SETUP.md): Local developer setup instructions for Windows, Linux, and macOS.
- [**DEVELOPMENT.md**](docs/DEVELOPMENT.md): Coding guidelines, testing strategy, and PR standards.
- [**DEPLOYMENT.md**](docs/DEPLOYMENT.md): Production container builds, Kubernetes/Cloud Run manifests, and CI.

---

## 🔒 Safety & Responsibility
Pashupati is designed to connect citizens with trained responders and veterinary clinics. The application does not provide automated diagnostic advice or replace qualified veterinary surgery.
