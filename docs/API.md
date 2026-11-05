# PASHUPATI — REST API Specification (`/api/v1/`)

## 1. Overview
All endpoints return standard JSON payloads.
Standard successful responses return `200 OK` or `201 Created`.
Protected endpoints require:
```http
Authorization: Bearer <jwt_token>
```

### 📖 Interactive Swagger & OpenAPI Documentation
- **Interactive Swagger UI (Browser)**: Open [`docs/swagger.html`](swagger.html) in your browser.
- **Embedded Server Swagger UI**: Available at `http://localhost:8080/swagger-ui` (or `http://localhost:8080/docs`) when the backend is running.
- **OpenAPI 3.0 Specification**: [`docs/openapi.yaml`](openapi.yaml) or `http://localhost:8080/api-docs/openapi.yaml`.

---

## 2. Authentication

### 2.1 Request OTP
```http
POST /api/v1/auth/otp/request
Content-Type: application/json

{
  "phone": "+919876543210"
}
```
**Response:**
```json
{
  "success": true,
  "message": "Verification code sent successfully.",
  "dev_otp": "123456"
}
```

### 2.2 Verify OTP
```http
POST /api/v1/auth/otp/verify
Content-Type: application/json

{
  "phone": "+919876543210",
  "otp": "123456",
  "name": "Aarav Sharma"
}
```
**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": "a0000000-0000-0000-0000-000000000001",
  "phone": "+919876543210",
  "name": "Aarav Sharma",
  "role": "VOLUNTEER"
}
```

---

## 3. SOS Management

### 3.1 Create SOS Request
```http
POST /api/v1/sos
Authorization: Bearer <token>
Content-Type: application/json

{
  "animal_type": "DOG",
  "emergency_type": "INJURED",
  "latitude": 12.9772,
  "longitude": 77.6418,
  "accuracy_meters": 5.0,
  "address": "Indiranagar 12th Main, Bengaluru",
  "landmark": "Near Corner House Ice Cream",
  "description": "Deep leg wound near tea stall",
  "requirements": ["FIRST_AID", "TRANSPORTATION"],
  "media_urls": [
    "https://images.unsplash.com/photo-1543466835-00a7907e9de1"
  ],
  "voice_memo_url": "https://example.com/voice.m4a"
}
```

### 3.2 List Nearby SOS Requests
```http
GET /api/v1/sos/nearby?latitude=12.9784&longitude=77.6408&radius_km=10
```

### 3.3 Get SOS Details & Milestones
```http
GET /api/v1/sos/:id
```

### 3.4 Check Potential Duplicates
```http
GET /api/v1/sos/check-duplicates?latitude=12.9772&longitude=77.6418&animal_type=DOG&radius_meters=500
```

### 3.5 Accept SOS (Respond)
```http
POST /api/v1/sos/:id/respond
Authorization: Bearer <token>
Content-Type: application/json

{
  "response_role": "PRIMARY",
  "eta_minutes": 6,
  "equipment_notes": "Bringing first aid kit and transport crate."
}
```

### 3.6 Resolve SOS (Rescue Outcome)
```http
POST /api/v1/sos/:id/resolve
Authorization: Bearer <token>
Content-Type: application/json

{
  "outcome_notes": "Animal stabilized and safely moved to CUPA Trauma Centre.",
  "recovery_image_urls": ["https://example.com/recovery.jpg"]
}
```

### 3.7 Cancel SOS
```http
POST /api/v1/sos/:id/cancel
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "False alarm / animal safely retrieved by owner."
}
```

---

## 4. Care Directory & Organizations

### 4.1 Search Nearby Centers
```http
GET /api/v1/organizations/nearby?latitude=12.9784&longitude=77.6408&radius_km=25&is_24_7=true
```

### 4.2 Get Center Details
```http
GET /api/v1/organizations/:id
```

---

## 5. User Activity & Profile

### 5.1 Get Current User Profile
```http
GET /api/v1/users/me
Authorization: Bearer <token>
```

### 5.2 Update Volunteer Availability & Radius
```http
PATCH /api/v1/users/me/volunteer-profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "is_available": true,
  "response_radius_km": 10,
  "vehicle_type": "TWO_WHEELER",
  "capabilities": ["FIRST_AID", "TRANSPORT", "VET_CARE"]
}
```

### 5.3 Get Rescue History
```http
GET /api/v1/activity
Authorization: Bearer <token>
```

