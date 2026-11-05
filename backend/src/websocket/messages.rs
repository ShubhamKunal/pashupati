use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", content = "payload")]
pub enum WsClientMessage {
    Ping,
    SubscribeSos { sos_id: Uuid },
    UnsubscribeSos { sos_id: Uuid },
    UpdateLocation {
        sos_id: Uuid,
        latitude: f64,
        longitude: f64,
        heading: Option<f32>,
        speed_kmh: Option<f32>,
    },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", content = "payload")]
pub enum WsServerMessage {
    Pong,
    Subscribed { sos_id: Uuid },
    Unsubscribed { sos_id: Uuid },
    LocationBroadcast {
        sos_id: Uuid,
        responder_id: Uuid,
        latitude: f64,
        longitude: f64,
        heading: Option<f32>,
        speed_kmh: Option<f32>,
        timestamp: chrono::DateTime<chrono::Utc>,
    },
    StatusChanged {
        sos_id: Uuid,
        previous_status: Option<String>,
        new_status: String,
        actor_id: Uuid,
        reason: Option<String>,
        timestamp: chrono::DateTime<chrono::Utc>,
    },
    ResponderAssigned {
        sos_id: Uuid,
        responder_id: Uuid,
        responder_name: String,
        eta_minutes: Option<i32>,
        equipment_notes: Option<String>,
    },
    Error { message: String },
}

