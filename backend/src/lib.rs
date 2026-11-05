pub mod auth;
pub mod config;
pub mod database;
pub mod errors;
pub mod middleware;
pub mod modules;
pub mod websocket;

use axum::{
    routing::get,
    Json, Router,
};
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::{
    auth::AppState,
    config::Config,
    websocket::{hub::WebSocketHub, ws_handler},
};

pub fn build_app(state: AppState) -> Router {
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let api_v1 = Router::new()
        .nest("/auth", auth::auth_router())
        .nest("/users", modules::users::users_router())
        .nest("/sos", modules::sos::sos_router())
        .nest("/sos", modules::responders::responders_router())
        .nest("/organizations", modules::organizations::organizations_router())
        .nest("/activity", modules::activity::activity_router())
        .nest("/notifications", modules::notifications::notifications_router())
        .nest("/uploads", modules::uploads::uploads_router())
        .route("/ws", get(ws_handler));

    Router::new()
        .route("/health", get(health_check_handler))
        .nest("/api/v1", api_v1)
        .layer(cors)
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

async fn health_check_handler() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "status": "healthy",
        "service": "pashupati-backend",
        "tagline": "Be the reason a life survives.",
        "version": "1.0.0"
    }))
}
