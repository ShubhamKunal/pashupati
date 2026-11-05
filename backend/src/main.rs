use std::sync::Arc;
use tokio::net::TcpListener;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

use pashupati_backend::{
    auth::AppState,
    build_app,
    config::Config,
    database::{create_pool, run_migrations},
    modules::notifications::start_outbox_worker,
    websocket::hub::WebSocketHub,
};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize structured tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::try_from_default_env().unwrap_or_else(|_| "info".into()))
        .with(tracing_subscriber::fmt::layer())
        .init();

    tracing::info!("Initializing PASHUPATI Animal Rescue Platform Backend...");

    let config = Config::from_env().map_err(|e| format!("Configuration error: {}", e))?;
    let config = Arc::new(config);

    // Database connection pool
    let pool = create_pool(&config.database_url).await?;

    // Run database migrations on startup
    if let Err(e) = run_migrations(&pool).await {
        tracing::warn!("Migration error: {}. Ensure PostgreSQL + PostGIS is running.", e);
    }

    // Spawn outbox background worker
    let pool_clone = pool.clone();
    tokio::spawn(async move {
        start_outbox_worker(pool_clone).await;
    });

    let ws_hub = Arc::new(WebSocketHub::new());

    let state = AppState {
        pool,
        config: config.clone(),
        ws_hub,
    };

    let app = build_app(state);

    let bind_addr = format!("{}:{}", config.host, config.port);
    let listener = TcpListener::bind(&bind_addr).await?;
    tracing::info!("🚀 PASHUPATI Backend listening on http://{}", bind_addr);

    axum::serve(listener, app).await?;

    Ok(())
}
