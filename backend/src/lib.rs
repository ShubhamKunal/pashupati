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
        .route("/swagger-ui", get(swagger_ui_handler))
        .route("/docs", get(swagger_ui_handler))
        .route("/api-docs/openapi.yaml", get(openapi_yaml_handler))
        .nest("/api/v1", api_v1)
        .layer(cors)
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}

const OPENAPI_SPEC: &str = include_str!("../openapi.yaml");

const SWAGGER_HTML: &str = r#"<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>PASHUPATI — Interactive API Documentation</title>
  <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.18.2/swagger-ui.css" />
  <style>
    body { margin: 0; background: #fafafa; font-family: sans-serif; }
    .topbar { background-color: #0A3623 !important; padding: 12px 24px; color: #F5F1E7; display: flex; align-items: center; justify-content: space-between; }
    .swagger-ui .topbar { display: none; }
  </style>
</head>
<body>
  <div class="topbar">
    <div style="font-weight: 700; font-size: 1.2rem;">🐾 PASHUPATI — API Documentation (OpenAPI 3.0)</div>
    <div style="font-size: 0.85rem; opacity: 0.85;">Be the reason a life survives.</div>
  </div>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5.18.2/swagger-ui-bundle.js" charset="UTF-8"></script>
  <script>
    window.onload = function() {
      window.ui = SwaggerUIBundle({
        url: "/api-docs/openapi.yaml",
        dom_id: '#swagger-ui',
        deepLinking: true,
        layout: "BaseLayout",
        docExpansion: "list",
        filter: true
      });
    };
  </script>
</body>
</html>"#;

async fn swagger_ui_handler() -> axum::response::Html<&'static str> {
    axum::response::Html(SWAGGER_HTML)
}

async fn openapi_yaml_handler() -> ([(axum::http::header::HeaderName, &'static str); 1], &'static str) {
    (
        [(axum::http::header::CONTENT_TYPE, "text/yaml; charset=utf-8")],
        OPENAPI_SPEC,
    )
}

async fn health_check_handler() -> Json<serde_json::Value> {
    Json(serde_json::json!({
        "status": "healthy",
        "service": "pashupati-backend",
        "tagline": "Be the reason a life survives.",
        "version": "1.0.0"
    }))
}
