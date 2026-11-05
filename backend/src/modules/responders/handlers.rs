use axum::{
    extract::{Extension, Path, State},
    routing::{delete, get, patch, post},
    Json, Router,
};
use uuid::Uuid;

use crate::{
    auth::{AppState, Claims},
    errors::AppError,
    middleware::require_auth,
    modules::{
        responders::models::{AcceptSosDto, ResponderItem, UpdateResponseDto},
        sos::{models::SosDetailResponse, repository::SosRepository},
    },
    websocket::messages::WsServerMessage,
};

pub fn responders_router() -> Router<AppState> {
    Router::new()
        .route("/:sos_id/responders", get(list_responders_handler))
        .route("/:sos_id/respond", post(accept_sos_handler).route_layer(axum::middleware::from_fn(require_auth)))
        .route("/:sos_id/respond", patch(update_response_handler).route_layer(axum::middleware::from_fn(require_auth)))
        .route("/:sos_id/respond", delete(withdraw_response_handler).route_layer(axum::middleware::from_fn(require_auth)))
}

pub async fn accept_sos_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(sos_id): Path<Uuid>,
    Json(payload): Json<AcceptSosDto>,
) -> Result<Json<SosDetailResponse>, AppError> {
    let mut tx = state.pool.begin().await?;

    // 1. Concurrency control: Lock the SOS row to prevent two competing primary responders
    let sos = sqlx::query!(
        "SELECT id, reporter_id, status, primary_responder_id FROM sos_requests WHERE id = $1 FOR UPDATE",
        sos_id
    )
    .fetch_optional(&mut *tx)
    .await?
    .ok_or_else(|| AppError::NotFound("SOS request not found.".into()))?;

    if sos.status == "RESOLVED" || sos.status == "CANCELLED" || sos.status == "EXPIRED" {
        return Err(AppError::BadRequest(format!("Cannot respond to an SOS with status '{}'.", sos.status)));
    }

    if sos.reporter_id == claims.sub {
        return Err(AppError::BadRequest("Reporter cannot respond to their own SOS.".into()));
    }

    let requested_role = payload.response_role.unwrap_or_else(|| "PRIMARY".to_string()).to_uppercase();
    let is_primary_available = sos.primary_responder_id.is_none();

    let final_role = if requested_role == "PRIMARY" {
        if is_primary_available {
            "PRIMARY"
        } else {
            // Already has primary responder; join as SUPPORTING
            "SUPPORTING"
        }
    } else {
        "SUPPORTING"
    };

    // Upsert response
    sqlx::query!(
        r#"
        INSERT INTO sos_responses (sos_id, responder_id, response_role, status, eta_minutes, equipment_notes)
        VALUES ($1, $2, $3, 'EN_ROUTE', $4, $5)
        ON CONFLICT (sos_id, responder_id) DO UPDATE
            SET response_role = $3,
                status = 'EN_ROUTE',
                eta_minutes = $4,
                equipment_notes = $5,
                updated_at = NOW()
        "#,
        sos_id,
        claims.sub,
        final_role,
        payload.eta_minutes.unwrap_or(10),
        payload.equipment_notes
    )
    .execute(&mut *tx)
    .await?;

    // If assigned as PRIMARY, update sos_requests status to RESPONDING / HELP_ARRIVING
    let new_status = if final_role == "PRIMARY" {
        sqlx::query!(
            "UPDATE sos_requests SET primary_responder_id = $1, status = 'RESPONDING', updated_at = NOW() WHERE id = $2",
            claims.sub,
            sos_id
        )
        .execute(&mut *tx)
        .await?;

        sqlx::query!(
            r#"
            INSERT INTO sos_status_history (sos_id, previous_status, new_status, actor_id, reason)
            VALUES ($1, $2, 'RESPONDING', $3, 'Primary responder accepted and is mobilizing.')
            "#,
            sos_id,
            sos.status,
            claims.sub
        )
        .execute(&mut *tx)
        .await?;

        "RESPONDING".to_string()
    } else {
        sos.status
    };

    // Enqueue notification for reporter
    let responder = sqlx::query!("SELECT name FROM users WHERE id = $1", claims.sub)
        .fetch_one(&mut *tx)
        .await?;

    sqlx::query!(
        r#"
        INSERT INTO notification_outbox (event_type, recipient_user_id, sos_id, title, body, payload_json)
        VALUES ('RESPONDER_ACCEPTED', $1, $2, '🐾 Help is on the way!', $3, $4)
        "#,
        sos.reporter_id,
        sos_id,
        format!("{} has accepted your SOS and is en route.", responder.name),
        serde_json::json!({
            "sos_id": sos_id,
            "responder_id": claims.sub,
            "role": final_role,
            "eta_minutes": payload.eta_minutes.unwrap_or(10)
        })
    )
    .execute(&mut *tx)
    .await?;

    tx.commit().await?;

    // Broadcast over WebSocket
    state.ws_hub.broadcast_sos(
        &sos_id,
        &WsServerMessage::ResponderAssigned {
            sos_id,
            responder_id: claims.sub,
            responder_name: responder.name,
            eta_minutes: payload.eta_minutes,
            equipment_notes: payload.equipment_notes,
        },
    );

    let detail = SosRepository::get_sos_by_id(&state.pool, sos_id).await?;
    Ok(Json(detail))
}

pub async fn update_response_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(sos_id): Path<Uuid>,
    Json(payload): Json<UpdateResponseDto>,
) -> Result<Json<SosDetailResponse>, AppError> {
    let mut tx = state.pool.begin().await?;

    let response = sqlx::query!(
        "SELECT response_role, status FROM sos_responses WHERE sos_id = $1 AND responder_id = $2",
        sos_id,
        claims.sub
    )
    .fetch_optional(&mut *tx)
    .await?
    .ok_or_else(|| AppError::NotFound("Active response record not found.".into()))?;

    let new_resp_status = payload.status.to_uppercase();

    sqlx::query!(
        "UPDATE sos_responses SET status = $1, eta_minutes = COALESCE($2, eta_minutes), updated_at = NOW() WHERE sos_id = $3 AND responder_id = $4",
        new_resp_status,
        payload.eta_minutes,
        sos_id,
        claims.sub
    )
    .execute(&mut *tx)
    .await?;

    // If primary responder marked ON_SITE, upgrade SOS to HELP_ARRIVING / ASSISTANCE_PROVIDED
    if response.response_role == "PRIMARY" {
        let sos_new_status = if new_resp_status == "ON_SITE" {
            "HELP_ARRIVING"
        } else {
            "RESPONDING"
        };

        sqlx::query!(
            "UPDATE sos_requests SET status = $1, updated_at = NOW() WHERE id = $2",
            sos_new_status,
            sos_id
        )
        .execute(&mut *tx)
        .await?;

        sqlx::query!(
            r#"
            INSERT INTO sos_status_history (sos_id, previous_status, new_status, actor_id, reason)
            VALUES ($1, $2, $3, $4, $5)
            "#,
            sos_id,
            response.status,
            sos_new_status,
            claims.sub,
            payload.notes.unwrap_or_else(|| format!("Responder status updated to {}", new_resp_status))
        )
        .execute(&mut *tx)
        .await?;
    }

    tx.commit().await?;

    let detail = SosRepository::get_sos_by_id(&state.pool, sos_id).await?;
    Ok(Json(detail))
}

pub async fn withdraw_response_handler(
    State(state): State<AppState>,
    Extension(claims): Extension<Claims>,
    Path(sos_id): Path<Uuid>,
) -> Result<Json<SosDetailResponse>, AppError> {
    let mut tx = state.pool.begin().await?;

    let response = sqlx::query!(
        "SELECT response_role FROM sos_responses WHERE sos_id = $1 AND responder_id = $2",
        sos_id,
        claims.sub
    )
    .fetch_optional(&mut *tx)
    .await?
    .ok_or_else(|| AppError::NotFound("Response record not found.".into()))?;

    sqlx::query!(
        "UPDATE sos_responses SET status = 'WITHDRAWN', updated_at = NOW() WHERE sos_id = $1 AND responder_id = $2",
        sos_id,
        claims.sub
    )
    .execute(&mut *tx)
    .await?;

    // If primary responder withdrew, reset SOS to OPEN if no other active responders
    if response.response_role == "PRIMARY" {
        let next_primary = sqlx::query!(
            "SELECT responder_id FROM sos_responses WHERE sos_id = $1 AND status != 'WITHDRAWN' ORDER BY created_at ASC LIMIT 1",
            sos_id
        )
        .fetch_optional(&mut *tx)
        .await?;

        if let Some(next) = next_primary {
            sqlx::query!(
                "UPDATE sos_requests SET primary_responder_id = $1 WHERE id = $2",
                next.responder_id,
                sos_id
            )
            .execute(&mut *tx)
            .await?;
        } else {
            sqlx::query!(
                "UPDATE sos_requests SET primary_responder_id = NULL, status = 'OPEN', updated_at = NOW() WHERE id = $1",
                sos_id
            )
            .execute(&mut *tx)
            .await?;

            sqlx::query!(
                r#"
                INSERT INTO sos_status_history (sos_id, previous_status, new_status, actor_id, reason)
                VALUES ($1, 'RESPONDING', 'OPEN', $2, 'Primary responder withdrew. Request re-opened for nearby volunteers.')
                "#,
                sos_id,
                claims.sub
            )
            .execute(&mut *tx)
            .await?;
        }
    }

    tx.commit().await?;

    let detail = SosRepository::get_sos_by_id(&state.pool, sos_id).await?;
    Ok(Json(detail))
}

pub async fn list_responders_handler(
    State(state): State<AppState>,
    Path(sos_id): Path<Uuid>,
) -> Result<Json<Vec<ResponderItem>>, AppError> {
    let rows = sqlx::query!(
        r#"
        SELECT 
            r.id as response_id, r.sos_id, r.responder_id,
            u.name as responder_name, u.phone as responder_phone, u.avatar_url as responder_avatar,
            r.response_role, r.status, r.eta_minutes, r.equipment_notes, r.created_at
        FROM sos_responses r
        JOIN users u ON r.responder_id = u.id
        WHERE r.sos_id = $1 AND r.status != 'WITHDRAWN'
        ORDER BY r.created_at ASC
        "#,
        sos_id
    )
    .fetch_all(&state.pool)
    .await?;

    let items = rows.into_iter().map(|r| ResponderItem {
        response_id: r.response_id,
        sos_id: r.sos_id,
        responder_id: r.responder_id,
        responder_name: r.responder_name,
        responder_phone: r.responder_phone,
        responder_avatar: r.responder_avatar,
        response_role: r.response_role,
        status: r.status,
        eta_minutes: r.eta_minutes,
        equipment_notes: r.equipment_notes,
        created_at: r.created_at,
    }).collect();

    Ok(Json(items))
}

