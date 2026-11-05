use axum::{
    extract::{Extension, Path, State},
    routing::{get, patch, post},
    Json, Router,
};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    auth::{AppState, Claims},
    errors::AppError,
    middleware::require_auth,
};

#[derive(Serialize)]
pub struct NotificationItem {
    pub id: Uuid,
    pub title: String,
    pub body: String,
    pub category: String,
    pub data_json: serde_json::Value,
    pub is_read: bool,
    pub created_at: DateTime<Utc>,
}

#[derive(Deserialize)]
pub struct RegisterDeviceDto {
    pub fcm_token: String,
    pub device_type: String, // ANDROID, IOS
}

#[derive(Serialize, Deserialize)]
pub struct NotificationPreferencesDto {
    pub emergency_alerts: bool,
    pub response_updates: bool,
    pub community_updates: bool,
    pub radius_km: i32,
}

pub fn notifications_router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_notifications_handler))
        .route("/:id/read", patch(mark_read_handler))
        .route("/devices/register", post(register_device_handler))
        .route("/preferences", get(get_preferences_handler).patch(update_preferences_handler))
        .route_layer(axum::middleware::from_fn(require_auth))
}

pub async fn list_notifications_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<Vec<NotificationItem>>, AppError> {
    let rows = sqlx::query!(
        "SELECT id, title, body, category, data_json, is_read, created_at FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 50",
        claims.sub
    )
    .fetch_all(&state.pool)
    .await?;

    let items = rows.into_iter().map(|r| NotificationItem {
        id: r.id,
        title: r.title,
        body: r.body,
        category: r.category,
        data_json: r.data_json,
        is_read: r.is_read,
        created_at: r.created_at,
    }).collect();

    Ok(Json(items))
}

pub async fn mark_read_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<Uuid>,
) -> Result<Json<serde_json::Value>, AppError> {
    sqlx::query!(
        "UPDATE notifications SET is_read = TRUE WHERE id = $1 AND user_id = $2",
        id,
        claims.sub
    )
    .execute(&state.pool)
    .await?;

    Ok(Json(serde_json::json!({ "success": true })))
}

pub async fn register_device_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<RegisterDeviceDto>,
) -> Result<Json<serde_json::Value>, AppError> {
    sqlx::query!(
        r#"
        INSERT INTO user_devices (user_id, fcm_token, device_type, is_active)
        VALUES ($1, $2, $3, TRUE)
        ON CONFLICT (user_id, fcm_token) DO UPDATE
            SET is_active = TRUE, updated_at = NOW()
        "#,
        claims.sub,
        payload.fcm_token,
        payload.device_type
    )
    .execute(&state.pool)
    .await?;

    Ok(Json(serde_json::json!({ "success": true, "message": "Device registered for push notifications." })))
}

pub async fn get_preferences_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<NotificationPreferencesDto>, AppError> {
    let pref = sqlx::query!(
        "SELECT emergency_alerts, response_updates, community_updates, radius_km FROM user_notification_preferences WHERE user_id = $1",
        claims.sub
    )
    .fetch_optional(&state.pool)
    .await?
    .unwrap_or(user_notification_preferences_row());

    Ok(Json(NotificationPreferencesDto {
        emergency_alerts: pref.emergency_alerts,
        response_updates: pref.response_updates,
        community_updates: pref.community_updates,
        radius_km: pref.radius_km,
    }))
}

pub async fn update_preferences_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<NotificationPreferencesDto>,
) -> Result<Json<NotificationPreferencesDto>, AppError> {
    sqlx::query!(
        r#"
        INSERT INTO user_notification_preferences (user_id, emergency_alerts, response_updates, community_updates, radius_km)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (user_id) DO UPDATE
            SET emergency_alerts = $2,
                response_updates = $3,
                community_updates = $4,
                radius_km = $5,
                updated_at = NOW()
        "#,
        claims.sub,
        payload.emergency_alerts,
        payload.response_updates,
        payload.community_updates,
        payload.radius_km
    )
    .execute(&state.pool)
    .await?;

    Ok(Json(payload))
}

struct DefaultPref {
    pub emergency_alerts: bool,
    pub response_updates: bool,
    pub community_updates: bool,
    pub radius_km: i32,
}

fn user_notification_preferences_row() -> DefaultPref {
    DefaultPref {
        emergency_alerts: true,
        response_updates: true,
        community_updates: true,
        radius_km: 5,
    }
}

