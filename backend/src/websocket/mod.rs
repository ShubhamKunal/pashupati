pub mod hub;
pub mod messages;

use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        Query, State,
    },
    response::Response,
};
use futures::{channel::mpsc::unbounded, StreamExt};
use serde::Deserialize;
use uuid::Uuid;

use crate::{
    auth::{jwt::verify_jwt, AppState},
    websocket::messages::{WsClientMessage, WsServerMessage},
};

#[derive(Deserialize)]
pub struct WsAuthQuery {
    pub token: String,
}

pub async fn ws_handler(
    ws: WebSocketUpgrade,
    Query(query): Query<WsAuthQuery>,
    State(state): State<AppState>,
) -> Response {
    let claims = match verify_jwt(&query.token, &state.config.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            return axum::http::StatusCode::UNAUTHORIZED.into_response();
        }
    };

    ws.on_upgrade(move |socket| handle_socket(socket, state, claims.sub))
}

async fn handle_socket(socket: WebSocket, state: AppState, user_id: Uuid) {
    let (mut sender, mut receiver) = socket.split();
    let (tx, mut rx) = unbounded::<Message>();

    state.ws_hub.register(user_id, tx);

    let send_task = tokio::spawn(async move {
        while let Some(msg) = rx.next().await {
            if sender.send(msg).await.is_err() {
                break;
            }
        }
    });

    let hub_clone = state.ws_hub.clone();
    let pool_clone = state.pool.clone();
    let recv_task = tokio::spawn(async move {
        while let Some(Ok(msg)) = receiver.next().await {
            if let Message::Text(text) = msg {
                if let Ok(client_msg) = serde_json::from_str::<WsClientMessage>(&text) {
                    match client_msg {
                        WsClientMessage::Ping => {
                            hub_clone.send_direct(&user_id, &WsServerMessage::Pong);
                        }
                        WsClientMessage::SubscribeSos { sos_id } => {
                            hub_clone.subscribe_sos(user_id, sos_id);
                            hub_clone.send_direct(&user_id, &WsServerMessage::Subscribed { sos_id });
                        }
                        WsClientMessage::UnsubscribeSos { sos_id } => {
                            hub_clone.unsubscribe_sos(&user_id, &sos_id);
                            hub_clone.send_direct(&user_id, &WsServerMessage::Unsubscribed { sos_id });
                        }
                        WsClientMessage::UpdateLocation {
                            sos_id,
                            latitude,
                            longitude,
                            heading,
                            speed_kmh,
                        } => {
                            // Update location sharing session in database
                            let _ = sqlx::query!(
                                r#"
                                INSERT INTO location_sharing_sessions (sos_id, responder_id, current_location, heading, speed_kmh, is_active, updated_at)
                                VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326), $5, $6, TRUE, NOW())
                                ON CONFLICT (sos_id, responder_id) DO UPDATE
                                    SET current_location = ST_SetSRID(ST_MakePoint($3, $4), 4326),
                                        heading = $5,
                                        speed_kmh = $6,
                                        is_active = TRUE,
                                        updated_at = NOW()
                                "#,
                                sos_id,
                                user_id,
                                longitude,
                                latitude,
                                heading,
                                speed_kmh
                            )
                            .execute(&pool_clone)
                            .await;

                            // Broadcast live location to SOS room subscribers
                            hub_clone.broadcast_sos(
                                &sos_id,
                                &WsServerMessage::LocationBroadcast {
                                    sos_id,
                                    responder_id: user_id,
                                    latitude,
                                    longitude,
                                    heading,
                                    speed_kmh,
                                    timestamp: chrono::Utc::now(),
                                },
                            );
                        }
                    }
                }
            }
        }
    });

    tokio::select! {
        _ = send_task => {},
        _ = recv_task => {},
    }

    state.ws_hub.unregister(&user_id);
}

