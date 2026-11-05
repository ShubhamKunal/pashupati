# PASHUPATI — Production Deployment Runbook

## 1. Containerized Cloud Architecture

Pashupati is designed to deploy on Kubernetes, AWS ECS, Google Cloud Run, or Railway using standard OCI container images.

```text
               ┌───────────────────────┐
               │ CloudFlare / AWS ALB  │
               └──────────┬────────────┘
                          │ HTTPS / WSS
                          ▼
               ┌───────────────────────┐
               │   pashupati-backend   │
               │   (Rust Axum Task)    │
               └────┬──────┬───────┬───┘
                    │      │       │
       ┌────────────┘      │       └─────────────┐
       ▼                   ▼                     ▼
┌──────────────┐   ┌───────────────┐   ┌───────────────────┐
│ Managed      │   │ S3 / Cloud    │   │ Firebase Cloud    │
│ PostgreSQL16 │   │ Storage Media │   │ Messaging (HTTPv1)│
│ + PostGIS3.4 │   └───────────────┘   └───────────────────┘
└──────────────┘
```

---

## 2. Environment Variables Checklist

Ensure these variables are injected into the production container runtime:

| Variable | Description | Example |
| :--- | :--- | :--- |
| `HOST` | Bind IP | `0.0.0.0` |
| `PORT` | HTTP/WS Port | `8080` |
| `DATABASE_URL` | PostgreSQL with PostGIS connection string | `postgres://user:pass@db.internal:5432/pashupati` |
| `JWT_SECRET` | High-entropy 256-bit secret | `*min 32 random characters*` |
| `JWT_EXPIRATION_HOURS` | Token validity | `720` (30 days) |
| `ENVIRONMENT` | Runtime mode | `production` |
| `FCM_SERVICE_ACCOUNT_KEY` | Google Service Account JSON | `{"type": "service_account", ...}` |
| `UPLOAD_BUCKET` | S3 Media Bucket | `pashupati-production-media` |
| `UPLOAD_ENDPOINT` | S3/MinIO Endpoint URL | `https://s3.ap-south-1.amazonaws.com` |

---

## 3. Building Production Artifacts

### 3.1 Backend Release Container
```bash
docker build -t pashupati/backend:latest -f backend/Dockerfile ./backend
```

### 3.2 Android Release APK / App Bundle
```bash
flutter build appbundle --release
```
Artifact generated at: `build/app/outputs/bundle/release/app-release.aab`.

### 3.3 iOS Release Archive
```bash
flutter build ipa --release
```
Artifact generated at: `build/ios/archive/Runner.xcarchive`.

