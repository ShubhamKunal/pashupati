use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SosRequestItem {
    pub id: Uuid,
    pub case_number: String,
    pub reporter_id: Uuid,
    pub reporter_name: Option<String>,
    pub status: String,
    pub animal_type: String,
    pub emergency_type: String,
    pub latitude: f64,
    pub longitude: f64,
    pub distance_meters: Option<f64>,
    pub accuracy_meters: Option<f32>,
    pub address: String,
    pub landmark: Option<String>,
    pub description: Option<String>,
    pub primary_responder_id: Option<Uuid>,
    pub primary_responder_name: Option<String>,
    pub primary_responder_phone: Option<String>,
    pub primary_responder_avatar: Option<String>,
    pub primary_responder_eta_minutes: Option<i32>,
    pub media: Vec<SosMediaItem>,
    pub requirements: Vec<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SosMediaItem {
    pub id: Uuid,
    pub media_type: String,
    pub url: String,
    pub thumbnail_url: Option<String>,
    pub caption: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SosStatusHistoryItem {
    pub id: Uuid,
    pub previous_status: Option<String>,
    pub new_status: String,
    pub actor_id: Uuid,
    pub actor_name: Option<String>,
    pub reason: Option<String>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SosDetailResponse {
    pub sos: SosRequestItem,
    pub status_history: Vec<SosStatusHistoryItem>,
    pub active_responders_count: i64,
}

#[derive(Debug, Deserialize)]
pub struct CreateSosDto {
    pub animal_type: String,
    pub emergency_type: String,
    pub latitude: f64,
    pub longitude: f64,
    pub accuracy_meters: Option<f32>,
    pub address: String,
    pub landmark: Option<String>,
    pub description: Option<String>,
    pub requirements: Vec<String>,
    pub media_urls: Vec<String>,
    pub voice_memo_url: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct NearbySosQuery {
    pub latitude: f64,
    pub longitude: f64,
    pub radius_km: Option<f64>,
    pub animal_type: Option<String>,
    pub status: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct CheckDuplicatesQuery {
    pub latitude: f64,
    pub longitude: f64,
    pub animal_type: Option<String>,
    pub radius_meters: Option<f64>,
}

#[derive(Debug, Deserialize)]
pub struct CancelSosDto {
    pub reason: String,
}

#[derive(Debug, Deserialize)]
pub struct ResolveSosDto {
    pub outcome_notes: Option<String>,
    pub recovery_image_urls: Option<Vec<String>>,
}

