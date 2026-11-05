use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct OrganizationItem {
    pub id: Uuid,
    pub name: String,
    pub org_type: String,
    pub description: Option<String>,
    pub address: String,
    pub latitude: f64,
    pub longitude: f64,
    pub distance_meters: Option<f64>,
    pub phone: String,
    pub emergency_phone: Option<String>,
    pub website: Option<String>,
    pub operating_hours: Option<String>,
    pub is_24_7: bool,
    pub is_verified: bool,
    pub facilities: Vec<String>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct NearbyOrganizationsQuery {
    pub latitude: f64,
    pub longitude: f64,
    pub radius_km: Option<f64>,
    pub org_type: Option<String>,
    pub is_24_7: Option<bool>,
}

