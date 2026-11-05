use axum::{
    extract::{Extension, State},
    routing::{get, patch, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{
    auth::{AppState, Claims},
    errors::AppError,
    middleware::require_auth,
};

#[derive(Serialize)]
pub struct UserProfileResponse {
    pub id: Uuid,
    pub phone: String,
    pub name: String,
    pub avatar_url: Option<String>,
    pub role: String,
    pub preferred_language: String,
    pub volunteer_profile: Option<VolunteerProfileDto>,
}

#[derive(Serialize, Deserialize)]
pub struct VolunteerProfileDto {
    pub is_available: bool,
    pub verification_status: String,
    pub vehicle_type: Option<String>,
    pub capabilities: Vec<String>,
    pub response_radius_km: i32,
    pub rescues_completed_count: i32,
    pub badge_label: Option<String>,
}

#[derive(Deserialize)]
pub struct UpdateUserDto {
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub preferred_language: Option<String>,
}

#[derive(Deserialize)]
pub struct UpdateVolunteerProfileDto {
    pub is_available: Option<bool>,
    pub vehicle_type: Option<String>,
    pub capabilities: Option<Vec<String>>,
    pub response_radius_km: Option<i32>,
}

#[derive(Deserialize)]
pub struct UpdateLocationDto {
    pub latitude: f64,
    pub longitude: f64,
}

pub fn users_router() -> Router<AppState> {
    Router::new()
        .route("/me", get(get_current_user_handler).patch(update_user_handler))
        .route("/me/volunteer-profile", patch(update_volunteer_profile_handler))
        .route("/me/location", post(update_location_handler))
        .route_layer(axum::middleware::from_fn(require_auth))
}

pub async fn get_current_user_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<UserProfileResponse>, AppError> {
    let user = sqlx::query!(
        "SELECT id, phone, name, avatar_url, role, preferred_language FROM users WHERE id = $1",
        claims.sub
    )
    .fetch_optional(&state.pool)
    .await?
    .ok_or_else(|| AppError::NotFound("User not found.".into()))?;

    let vol = sqlx::query!(
        r#"
        SELECT is_available, verification_status, vehicle_type, capabilities,
               response_radius_km, rescues_completed_count, badge_label
        FROM user_volunteer_profiles
        WHERE user_id = $1
        "#,
        claims.sub
    )
    .fetch_optional(&state.pool)
    .await?;

    let volunteer_profile = vol.map(|v| VolunteerProfileDto {
        is_available: v.is_available,
        verification_status: v.verification_status,
        vehicle_type: v.vehicle_type,
        capabilities: v.capabilities,
        response_radius_km: v.response_radius_km,
        rescues_completed_count: v.rescues_completed_count,
        badge_label: v.badge_label,
    });

    Ok(Json(UserProfileResponse {
        id: user.id,
        phone: user.phone,
        name: user.name,
        avatar_url: user.avatar_url,
        role: user.role,
        preferred_language: user.preferred_language,
        volunteer_profile,
    }))
}

pub async fn update_user_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<UpdateUserDto>,
) -> Result<Json<UserProfileResponse>, AppError> {
    sqlx::query!(
        r#"
        UPDATE users
        SET name = COALESCE($1, name),
            avatar_url = COALESCE($2, avatar_url),
            preferred_language = COALESCE($3, preferred_language),
            updated_at = NOW()
        WHERE id = $4
        "#,
        payload.name,
        payload.avatar_url,
        payload.preferred_language,
        claims.sub
    )
    .execute(&state.pool)
    .await?;

    get_current_user_handler(State(state), Extension(claims)).await
}

pub async fn update_volunteer_profile_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<UpdateVolunteerProfileDto>,
) -> Result<Json<UserProfileResponse>, AppError> {
    sqlx::query!(
        r#"
        INSERT INTO user_volunteer_profiles (user_id, is_available, vehicle_type, capabilities, response_radius_km)
        VALUES ($1, COALESCE($2, TRUE), COALESCE($3, 'NONE'), COALESCE($4, '{}'), COALESCE($5, 5))
        ON CONFLICT (user_id) DO UPDATE
            SET is_available = COALESCE($2, user_volunteer_profiles.is_available),
                vehicle_type = COALESCE($3, user_volunteer_profiles.vehicle_type),
                capabilities = COALESCE($4, user_volunteer_profiles.capabilities),
                response_radius_km = COALESCE($5, user_volunteer_profiles.response_radius_km),
                updated_at = NOW()
        "#,
        claims.sub,
        payload.is_available,
        payload.vehicle_type,
        payload.capabilities.as_deref(),
        payload.response_radius_km
    )
    .execute(&state.pool)
    .await?;

    get_current_user_handler(State(state), Extension(claims)).await
}

pub async fn update_location_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<UpdateLocationDto>,
) -> Result<Json<serde_json::Value>, AppError> {
    sqlx::query!(
        r#"
        UPDATE user_volunteer_profiles
        SET last_known_location = ST_SetSRID(ST_MakePoint($1, $2), 4326),
            updated_at = NOW()
        WHERE user_id = $3
        "#,
        payload.longitude,
        payload.latitude,
        claims.sub
    )
    .execute(&state.pool)
    .await?;

    Ok(Json(serde_json::json!({ "success": true, "message": "Location updated" })))
}

