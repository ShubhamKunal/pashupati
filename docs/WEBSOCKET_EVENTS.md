# PASHUPATI — WebSocket Real-Time Protocol (`/api/v1/ws`)

## 1. Connection Endpoint
```text
ws://localhost:8080/api/v1/ws?token=<jwt_token>
```
Authentication occurs during the HTTP WebSocket upgrade handshake. Connections without a valid JWT are rejected with `401 Unauthorized`.

---

## 2. Client-to-Server Messages

### 2.1 Heartbeat Ping
```json
{
  "type": "Ping"
}
```

### 2.2 Subscribe to SOS Case Room
```json
{
  "type": "SubscribeSos",
  "payload": {
    "sos_id": "c0000000-0000-0000-0000-000000000001"
  }
}
```

### 2.3 Unsubscribe from SOS Case Room
```json
{
  "type": "UnsubscribeSos",
  "payload": {
    "sos_id": "c0000000-0000-0000-0000-000000000001"
  }
}
```

### 2.4 Stream Responder Telematics
*Sent by assigned responder when active on dispatch.*
```json
{
  "type": "UpdateLocation",
  "payload": {
    "sos_id": "c0000000-0000-0000-0000-000000000001",
    "latitude": 12.9750,
    "longitude": 77.6350,
    "heading": 45.0,
    "speed_kmh": 28.5
  }
}
```

---

## 3. Server-to-Client Broadcast Events

### 3.1 Heartbeat Pong
```json
{
  "type": "Pong"
}
```

### 3.2 Live Location Broadcast
*Broadcast to all subscribers in the SOS room.*
```json
{
  "type": "LocationBroadcast",
  "payload": {
    "sos_id": "c0000000-0000-0000-0000-000000000001",
    "responder_id": "a0000000-0000-0000-0000-000000000002",
    "latitude": 12.9750,
    "longitude": 77.6350,
    "heading": 45.0,
    "speed_kmh": 28.5,
    "timestamp": "2026-11-05T12:06:00Z"
  }
}
```

### 3.3 Responder Assigned
```json
{
  "type": "ResponderAssigned",
  "payload": {
    "sos_id": "c0000000-0000-0000-0000-000000000001",
    "responder_id": "a0000000-0000-0000-0000-000000000002",
    "responder_name": "Dr. Rohan Verma",
    "eta_minutes": 6,
    "equipment_notes": "Contributing: Bringing first-aid kit & sterilized gauze, animal transport crate."
  }
}
```

### 3.4 Status Changed
```json
{
  "type": "StatusChanged",
  "payload": {
    "sos_id": "c0000000-0000-0000-0000-000000000001",
    "previous_status": "RESPONDING",
    "new_status": "HELP_ARRIVING",
    "actor_id": "a0000000-0000-0000-0000-000000000002",
    "reason": "Responder arrived at Corner House tea stall site.",
    "timestamp": "2026-11-05T12:08:00Z"
  }
}
```

