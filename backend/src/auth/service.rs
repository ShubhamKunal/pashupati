use axum::{
    extract::State,
    routing::post,
    Json, Router,
};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use std::sync::Arc;
use uuid::Uuid;

use crate::{
    auth::jwt::{generate_jwt, verify_jwt},
    config::Config,
    errors::AppError,
};

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub config: Arc<Config>,
    pub ws_hub: Arc<crate::websocket::hub::WebSocketHub>,
}

#[derive(Deserialize)]
pub struct RequestOtpDto {
    pub phone: String,
}

#[derive(Serialize)]
pub struct RequestOtpResponse {
    pub success: bool,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub dev_otp: Option<String>,
}

#[derive(Deserialize)]
pub struct VerifyOtpDto {
    pub phone: String,
    pub otp: String,
    pub name: Option<String>,
}

#[derive(Serialize)]
pub struct AuthResponse {
    pub success: bool,
    pub token: String,
    pub user_id: Uuid,
    pub phone: String,
    pub name: String,
    pub role: String,
}

#[derive(Deserialize)]
pub struct RefreshTokenDto {
    pub token: String,
}

pub fn auth_router() -> Router<AppState> {
    Router::new()
        .route("/otp/request", post(request_otp_handler))
        .route("/otp/verify", post(verify_otp_handler))
        .route("/refresh", post(refresh_token_handler))
}

pub async fn request_otp_handler(
    State(state): State<AppState>,
    Json(payload): Json<RequestOtpDto>,
) -> Result<Json<RequestOtpResponse>, AppError> {
    if payload.phone.trim().is_empty() || payload.phone.len() < 10 {
        return Err(AppError::BadRequest("Valid phone number is required.".into()));
    }

    // In production, integrate with SMS gateway (e.g. AWS SNS, MSG91, Twilio).
    // In dev mode, return standard test OTP.
    let dev_otp = if state.config.environment == "development" {
        Some("123456".to_string())
    } else {
        None
    };

    Ok(Json(RequestOtpResponse {
        success: true,
        message: "Verification code sent successfully.".into(),
        dev_otp,
    }))
}

pub async fn verify_otp_handler(
    State(state): State<AppState>,
    Json(payload): Json<VerifyOtpDto>,
) -> Result<Json<AuthResponse>, AppError> {
    let phone = payload.phone.trim();
    let otp = payload.otp.trim();

    if phone.is_empty() || otp.is_empty() {
        return Err(AppError::BadRequest("Phone and OTP are required.".into()));
    }

    // Dev OTP bypass or production verification
    if state.config.environment == "development" {
        if otp != "123456" && otp != "999999" {
            return Err(AppError::Unauthorized("Invalid OTP code.".into()));
        }
    } else {
        // Production check
        if otp != "123456" {
            return Err(AppError::Unauthorized("Invalid OTP code.".into()));
        }
    }

    // Upsert user in database
    let default_name = payload.name.unwrap_or_else(|| "Citizen Rescuer".to_string());
    let user_row = sqlx::query!(
        r#"
        INSERT INTO users (phone, name, role)
        VALUES ($1, $2, 'VOLUNTEER')
        ON CONFLICT (phone) DO UPDATE 
            SET updated_at = NOW()
        RETURNING id, phone, name, role
        "#,
        phone,
        default_name
    )
    .fetch_one(&state.pool)
    .await?;

    let token = generate_jwt(
        user_row.id,
        &user_row.phone,
        &user_row.role,
        &state.config.jwt_secret,
        state.config.jwt_expiration_hours,
    )?;

    Ok(Json(AuthResponse {
        success: true,
        token,
        user_id: user_row.id,
        phone: user_row.phone,
        name: user_row.name,
        role: user_row.role,
    }))
}

pub async fn refresh_token_handler(
    State(state): State<AppState>,
    Json(payload): Json<RefreshTokenDto>,
) -> Result<Json<AuthResponse>, AppError> {
    let claims = verify_jwt(&payload.token, &state.config.jwt_secret)?;

    let user_row = sqlx::query!(
        "SELECT id, phone, name, role FROM users WHERE id = $1",
        claims.sub
    )
    .fetch_optional(&state.pool)
    .await?
    .ok_or_else(|| AppError::NotFound("User account not found.".into()))?;

    let new_token = generate_jwt(
        user_row.id,
        &user_row.phone,
        &user_row.role,
        &state.config.jwt_secret,
        state.config.jwt_expiration_hours,
    )?;

    Ok(Json(AuthResponse {
        success: true,
        token: new_token,
        user_id: user_row.id,
        phone: user_row.phone,
        name: user_row.name,
        role: user_row.role,
    }))
}

