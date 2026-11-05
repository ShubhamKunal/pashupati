use axum::{
    extract::State,
    routing::post,
    Json, Router,
};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::{auth::AppState, errors::AppError, middleware::require_auth};

#[derive(Deserialize)]
pub struct PresignUploadDto {
    pub file_name: String,
    pub mime_type: String,
    pub file_size_bytes: usize,
}

#[derive(Serialize)]
pub struct PresignUploadResponse {
    pub upload_url: String,
    pub public_url: String,
    pub key: String,
}

pub fn uploads_router() -> Router<AppState> {
    Router::new()
        .route("/presign", post(presign_upload_handler))
        .route_layer(axum::middleware::from_fn(require_auth))
}

pub async fn presign_upload_handler(
    State(state): State<AppState>,
    Json(payload): Json<PresignUploadDto>,
) -> Result<Json<PresignUploadResponse>, AppError> {
    // Validate MIME types
    let allowed_mimes = ["image/jpeg", "image/png", "image/webp", "audio/m4a", "audio/mp4", "audio/aac", "audio/ogg"];
    if !allowed_mimes.contains(&payload.mime_type.as_str()) {
        return Err(AppError::BadRequest("Unsupported file type. Only JPEG, PNG, WEBP, and audio notes allowed.".into()));
    }

    // Limit size to 25MB
    if payload.file_size_bytes > 25 * 1024 * 1024 {
        return Err(AppError::BadRequest("File exceeds 25MB limit.".into()));
    }

    let file_id = Uuid::new_v4();
    let ext = payload.file_name.split('.').last().unwrap_or("bin");
    let key = format!("uploads/{}/{}.{}", chrono::Utc::now().format("%Y/%m"), file_id, ext);

    let public_url = format!("{}/{}/{}", state.config.upload_endpoint, state.config.upload_bucket, key);
    let upload_url = format!("{}/direct-upload/{}", state.config.upload_endpoint, key);

    Ok(Json(PresignUploadResponse {
        upload_url,
        public_url,
        key,
    }))
}

