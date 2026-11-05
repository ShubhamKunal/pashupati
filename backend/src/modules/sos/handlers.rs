use axum::{
    extract::{Extension, Path, Query, State},
    routing::{get, post},
    Json, Router,
};
use uuid::Uuid;

use crate::{
    auth::{AppState, Claims},
    errors::AppError,
    middleware::require_auth,
    modules::sos::{
        duplicate_detector::find_potential_duplicates,
        models::{
            CancelSosDto, CheckDuplicatesQuery, CreateSosDto, NearbySosQuery, ResolveSosDto,
            SosDetailResponse, SosRequestItem,
        },
        repository::SosRepository,
        state_machine::validate_transition,
    },
    websocket::messages::WsServerMessage,
};

pub fn sos_router() -> Router<AppState> {
    Router::new()
        .route("/nearby", get(list_nearby_sos_handler))
        .route("/check-duplicates", get(check_duplicates_handler))
        .route("/:id", get(get_sos_by_id_handler))
        .route("/", post(create_sos_handler).route_layer(axum::middleware::from_fn(require_auth)))
        .route("/:id/cancel", post(cancel_sos_handler).route_layer(axum::middleware::from_fn(require_auth)))
        .route("/:id/resolve", post(resolve_sos_handler).route_layer(axum::middleware::from_fn(require_auth)))
}

pub async fn create_sos_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Json(payload): Json<CreateSosDto>,
) -> Result<Json<SosRequestItem>, AppError> {
    if payload.latitude < -90.0 || payload.latitude > 90.0 || payload.longitude < -180.0 || payload.longitude > 180.0 {
        return Err(AppError::BadRequest("Invalid GPS coordinates.".into()));
    }
    if payload.address.trim().is_empty() {
        return Err(AppError::BadRequest("Address is required.".into()));
    }

    let sos = SosRepository::create_sos(&state.pool, claims.sub, payload).await?;

    // Broadcast over WebSocket
    state.ws_hub.broadcast_sos(
        &sos.id,
        &WsServerMessage::StatusChanged {
            sos_id: sos.id,
            previous_status: None,
            new_status: sos.status.clone(),
            actor_id: claims.sub,
            reason: Some("Emergency alert filed with photo and pinpoint telemetry.".into()),
            timestamp: chrono::Utc::now(),
        },
    );

    Ok(Json(sos))
}

pub async fn get_sos_by_id_handler(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
) -> Result<Json<SosDetailResponse>, AppError> {
    let detail = SosRepository::get_sos_by_id(&state.pool, id).await?;
    Ok(Json(detail))
}

pub async fn list_nearby_sos_handler(
    State(state): State<AppState>,
    Query(query): Query<NearbySosQuery>,
) -> Result<Json<Vec<SosRequestItem>>, AppError> {
    let items = SosRepository::list_nearby(&state.pool, query).await?;
    Ok(Json(items))
}

pub async fn check_duplicates_handler(
    State(state): State<AppState>,
    Query(query): Query<CheckDuplicatesQuery>,
) -> Result<Json<Vec<SosRequestItem>>, AppError> {
    let radius = query.radius_meters.unwrap_or(500.0);
    let duplicates = find_potential_duplicates(
        &state.pool,
        query.latitude,
        query.longitude,
        query.animal_type.as_deref(),
        radius,
    )
    .await?;

    Ok(Json(duplicates))
}

pub async fn cancel_sos_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<Uuid>,
    Json(payload): Json<CancelSosDto>,
) -> Result<Json<SosDetailResponse>, AppError> {
    let current_sos = SosRepository::get_sos_by_id(&state.pool, id).await?;

    // Only reporter or admin can cancel
    if current_sos.sos.reporter_id != claims.sub && claims.role != "ADMIN" {
        return Err(AppError::Forbidden("Only the reporter can cancel this SOS request.".into()));
    }

    validate_transition(&current_sos.sos.status, "CANCELLED")?;

    let mut tx = state.pool.begin().await?;

    sqlx::query!(
        "UPDATE sos_requests SET status = 'CANCELLED', updated_at = NOW() WHERE id = $1",
        id
    )
    .execute(&mut *tx)
    .await?;

    sqlx::query!(
        r#"
        INSERT INTO sos_status_history (sos_id, previous_status, new_status, actor_id, reason)
        VALUES ($1, $2, 'CANCELLED', $3, $4)
        "#,
        id,
        current_sos.sos.status,
        claims.sub,
        payload.reason
    )
    .execute(&mut *tx)
    .await?;

    tx.commit().await?;

    // Broadcast cancellation over WebSocket
    state.ws_hub.broadcast_sos(
        &id,
        &WsServerMessage::StatusChanged {
            sos_id: id,
            previous_status: Some(current_sos.sos.status),
            new_status: "CANCELLED".to_string(),
            actor_id: claims.sub,
            reason: Some(payload.reason),
            timestamp: chrono::Utc::now(),
        },
    );

    let updated = SosRepository::get_sos_by_id(&state.pool, id).await?;
    Ok(Json(updated))
}

pub async fn resolve_sos_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(id): Path<Uuid>,
    Json(payload): Json<ResolveSosDto>,
) -> Result<Json<SosDetailResponse>, AppError> {
    let current_sos = SosRepository::get_sos_by_id(&state.pool, id).await?;

    // Reporter, assigned primary responder, or admin can resolve
    let is_authorized = current_sos.sos.reporter_id == claims.sub
        || current_sos.sos.primary_responder_id == Some(claims.sub)
        || claims.role == "ADMIN";

    if !is_authorized {
        return Err(AppError::Forbidden("Not authorized to resolve this SOS case.".into()));
    }

    validate_transition(&current_sos.sos.status, "RESOLVED")?;

    let mut tx = state.pool.begin().await?;

    sqlx::query!(
        "UPDATE sos_requests SET status = 'RESOLVED', updated_at = NOW() WHERE id = $1",
        id
    )
    .execute(&mut *tx)
    .await?;

    let reason = payload.outcome_notes.unwrap_or_else(|| "Rescue successfully completed and animal stabilized.".into());

    sqlx::query!(
        r#"
        INSERT INTO sos_status_history (sos_id, previous_status, new_status, actor_id, reason)
        VALUES ($1, $2, 'RESOLVED', $3, $4)
        "#,
        id,
        current_sos.sos.status,
        claims.sub,
        reason
    )
    .execute(&mut *tx)
    .await?;

    // Mark responder responses completed
    sqlx::query!(
        "UPDATE sos_responses SET status = 'COMPLETED', updated_at = NOW() WHERE sos_id = $1",
        id
    )
    .execute(&mut *tx)
    .await?;

    // Deactivate location sharing
    sqlx::query!(
        "UPDATE location_sharing_sessions SET is_active = FALSE, updated_at = NOW() WHERE sos_id = $1",
        id
    )
    .execute(&mut *tx)
    .await?;

    tx.commit().await?;

    // Broadcast over WebSocket
    state.ws_hub.broadcast_sos(
        &id,
        &WsServerMessage::StatusChanged {
            sos_id: id,
            previous_status: Some(current_sos.sos.status),
            new_status: "RESOLVED".to_string(),
            actor_id: claims.sub,
            reason: Some(reason),
            timestamp: chrono::Utc::now(),
        },
    );

    let updated = SosRepository::get_sos_by_id(&state.pool, id).await?;
    Ok(Json(updated))
}

