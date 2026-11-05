use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct AcceptSosDto {
    pub response_role: Option<String>, // PRIMARY or SUPPORTING
    pub eta_minutes: Option<i32>,
    pub equipment_notes: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateResponseDto {
    pub status: String, // EN_ROUTE, ON_SITE, WITHDRAWN
    pub eta_minutes: Option<i32>,
    pub notes: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ResponderItem {
    pub response_id: Uuid,
    pub sos_id: Uuid,
    pub responder_id: Uuid,
    pub responder_name: String,
    pub responder_phone: String,
    pub responder_avatar: Option<String>,
    pub response_role: String,
    pub status: String,
    pub eta_minutes: Option<i32>,
    pub equipment_notes: Option<String>,
    pub created_at: DateTime<Utc>,
}

