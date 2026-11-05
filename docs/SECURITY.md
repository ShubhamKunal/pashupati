# PASHUPATI — Security, Privacy & Integrity Policies

## 1. Authentication & Session Security
- **JWT Standard**: 256-bit HMAC (`HS256`) tokens with strict expiration (`exp`) validation.
- **Hardware-Backed Storage**: Client tokens are stored in Android KeyStore and iOS Keychain via `flutter_secure_storage`.
- **Zero Sensitive Data in SharedPreferences**: SharedPreferences is strictly reserved for non-sensitive UI preferences.

---

## 2. Location Privacy Controls
- **No Continuous Tracking**: Pashupati **never** performs continuous passive background tracking of users.
- **Mission-Scoped Telematics**: Responder location coordinates are only transmitted when a responder explicitly accepts an active SOS and enables location sharing.
- **Automatic Session Termination**: When an SOS is marked `RESOLVED` or `CANCELLED`, all location sharing sessions are immediately deactivated in PostgreSQL (`is_active = FALSE`).
- **GPS Fuzzing on Public Discovery**: Public SOS feeds return generalized road coordinates (`ST_SnapToGrid` or rounded to 3 decimal places) rather than raw pinpoint device coordinates.

---

## 3. Contact & Identity Protection
- **Phone Number Masking**: The citizen reporter's phone number is masked by default on public discovery feeds. Direct dial is only made available once a verified responder accepts the rescue case.
- **Rate Limiting**: SOS creation endpoints are rate-limited to 3 requests per 10 minutes per IP/user to prevent denial-of-service or spam incident filings.

---

## 4. Input & Media Validation
- **Upload Restrictions**:
  - Image MIME types: `image/jpeg`, `image/png`, `image/webp`.
  - Audio MIME types: `audio/m4a`, `audio/mp4`, `audio/aac`, `audio/ogg`.
  - Maximum upload size: strictly capped at `25 MB`.
- **SQL Injection Prevention**: All queries utilize parameterized SQLx prepared statements. No dynamic raw SQL string interpolation is permitted.

---

## 5. Auditability & Abuse Mitigation
- Every state transition is recorded in `sos_status_history` with the `actor_id`, `previous_status`, `new_status`, timestamp, and human-readable reason.
- Unauthorized attempts to modify or resolve cases return `403 Forbidden` and log structured warnings in tracing.

