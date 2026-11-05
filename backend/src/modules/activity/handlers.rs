use axum::{
    extract::{Extension, State},
    routing::get,
    Json, Router,
};
use serde::Serialize;
use uuid::Uuid;

use crate::{
    auth::{AppState, Claims},
    errors::AppError,
    middleware::require_auth,
    modules::sos::models::SosRequestItem,
};

#[derive(Serialize)]
pub struct UserActivityResponse {
    pub reported_sos: Vec<SosRequestItem>,
    pub responses_participated: Vec<SosRequestItem>,
    pub rescues_resolved_count: i64,
}

pub fn activity_router() -> Router<AppState> {
    Router::new()
        .route("/", get(get_user_activity_handler))
        .route_layer(axum::middleware::from_fn(require_auth))
}

pub async fn get_user_activity_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
) -> Result<Json<UserActivityResponse>, AppError> {
    // 1. Reported cases
    let reported_items = crate::modules::sos::repository::SosRepository::list_nearby(
        &state.pool,
        crate::modules::sos::models::NearbySosQuery {
            latitude: 0.0,
            longitude: 0.0,
            radius_km: Some(50000.0), // All
            animal_type: None,
            status: None,
        },
    )
    .await?;

    let my_reported: Vec<_> = reported_items
        .into_iter()
        .filter(|s| s.reporter_id == claims.sub)
        .collect();

    // 2. Responded cases
    let responded_sos_ids = sqlx::query!(
        "SELECT DISTINCT sos_id FROM sos_responses WHERE responder_id = $1",
        claims.sub
    )
    .fetch_all(&state.pool)
    .await?;

    let mut my_responses = Vec::new();
    for row in responded_sos_ids {
        if let Ok(detail) = crate::modules::sos::repository::SosRepository::get_sos_by_id(&state.pool, row.sos_id).await {
            my_responses.push(detail.sos);
        }
    }

    let resolved_count = sqlx::query_scalar!(
        r#"
        SELECT COUNT(*)
        FROM sos_requests
        WHERE (reporter_id = $1 OR primary_responder_id = $1)
          AND status = 'RESOLVED'
        "#,
        claims.sub
    )
    .fetch_one(&state.pool)
    .await?
    .unwrap_or(0);

    Ok(Json(UserActivityResponse {
        reported_sos: my_reported,
        responses_participated: my_responses,
        rescues_resolved_count: resolved_count,
    }))
}

