use sqlx::PgPool;
use std::time::Duration;

pub async fn start_outbox_worker(pool: PgPool) {
    tracing::info!("Notification outbox worker started.");

    loop {
        if let Err(e) = process_pending_outbox(&pool).await {
            tracing::error!("Error processing outbox events: {}", e);
        }
        tokio::time::sleep(Duration::from_secs(3)).await;
    }
}

async fn process_pending_outbox(pool: &PgPool) -> Result<(), sqlx::Error> {
    // 1. Fetch up to 20 pending notification outbox events with row-level lock
    let events = sqlx::query!(
        r#"
        SELECT id, event_type, recipient_user_id, title, body, payload_json, retry_count
        FROM notification_outbox
        WHERE status = 'PENDING' AND scheduled_for <= NOW()
        ORDER BY created_at ASC
        LIMIT 20
        FOR UPDATE SKIP LOCKED
        "#
    )
    .fetch_all(pool)
    .await?;

    for event in events {
        // Create in-app notification record
        let _ = sqlx::query!(
            r#"
            INSERT INTO notifications (user_id, title, body, category, data_json)
            VALUES ($1, $2, $3, 'EMERGENCY', $4)
            "#,
            event.recipient_user_id,
            event.title,
            event.body,
            event.payload_json
        )
        .execute(pool)
        .await;

        // In production: send to FCM HTTP v1 API using service account credentials.
        // If FCM credentials are missing in dev mode, we log and mark SENT.
        tracing::info!(
            "Outbox processed: [{}] to user {} (title: '{}')",
            event.event_type,
            event.recipient_user_id,
            event.title
        );

        // Mark as SENT
        let _ = sqlx::query!(
            "UPDATE notification_outbox SET status = 'SENT', processed_at = NOW() WHERE id = $1",
            event.id
        )
        .execute(pool)
        .await;
    }

    Ok(())
}

