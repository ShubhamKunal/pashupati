use sqlx::PgPool;
use crate::{errors::AppError, modules::sos::models::SosRequestItem};

pub async fn find_potential_duplicates(
    pool: &PgPool,
    latitude: f64,
    longitude: f64,
    animal_type: Option<&str>,
    radius_meters: f64,
) -> Result<Vec<SosRequestItem>, AppError> {
    // Look for active (non-terminal) requests created within the last 4 hours within radius_meters
    let rows = sqlx::query!(
        r#"
        SELECT 
            s.id, s.case_number, s.reporter_id, u.name as reporter_name,
            s.status, s.animal_type, s.emergency_type,
            ST_Y(s.location::geometry) as latitude,
            ST_X(s.location::geometry) as longitude,
            ST_Distance(s.location, ST_SetSRID(ST_MakePoint($1, $2), 4326)) as distance_meters,
            s.accuracy_meters, s.address, s.landmark, s.description,
            s.primary_responder_id, r.name as primary_responder_name,
            r.phone as primary_responder_phone, r.avatar_url as primary_responder_avatar,
            res.eta_minutes as primary_responder_eta_minutes,
            s.created_at, s.updated_at
        FROM sos_requests s
        LEFT JOIN users u ON s.reporter_id = u.id
        LEFT JOIN users r ON s.primary_responder_id = r.id
        LEFT JOIN sos_responses res ON s.id = res.sos_id AND s.primary_responder_id = res.responder_id
        WHERE 
            s.status IN ('OPEN', 'RESPONDING', 'HELP_ARRIVING')
            AND ST_DWithin(s.location, ST_SetSRID(ST_MakePoint($1, $2), 4326), $3)
            AND ($4::TEXT IS NULL OR s.animal_type = $4)
            AND s.created_at >= NOW() - INTERVAL '4 hours'
        ORDER BY distance_meters ASC
        LIMIT 5
        "#,
        longitude,
        latitude,
        radius_meters,
        animal_type
    )
    .fetch_all(pool)
    .await?;

    let mut results = Vec::new();
    for row in rows {
        // Fetch media
        let media_rows = sqlx::query!(
            "SELECT id, media_type, url, thumbnail_url, caption FROM sos_media WHERE sos_id = $1 ORDER BY sort_order ASC",
            row.id
        )
        .fetch_all(pool)
        .await?;

        let media = media_rows.into_iter().map(|m| crate::modules::sos::models::SosMediaItem {
            id: m.id,
            media_type: m.media_type,
            url: m.url,
            thumbnail_url: m.thumbnail_url,
            caption: m.caption,
        }).collect();

        // Fetch requirements
        let req_rows = sqlx::query!(
            "SELECT requirement_type FROM sos_requirements WHERE sos_id = $1",
            row.id
        )
        .fetch_all(pool)
        .await?;

        let requirements = req_rows.into_iter().map(|r| r.requirement_type).collect();

        results.push(SosRequestItem {
            id: row.id,
            case_number: row.case_number,
            reporter_id: row.reporter_id,
            reporter_name: row.reporter_name,
            status: row.status,
            animal_type: row.animal_type,
            emergency_type: row.emergency_type,
            latitude: row.latitude.unwrap_or(0.0),
            longitude: row.longitude.unwrap_or(0.0),
            distance_meters: row.distance_meters,
            accuracy_meters: row.accuracy_meters,
            address: row.address,
            landmark: row.landmark,
            description: row.description,
            primary_responder_id: row.primary_responder_id,
            primary_responder_name: row.primary_responder_name,
            primary_responder_phone: row.primary_responder_phone,
            primary_responder_avatar: row.primary_responder_avatar,
            primary_responder_eta_minutes: row.primary_responder_eta_minutes,
            media,
            requirements,
            created_at: row.created_at,
            updated_at: row.updated_at,
        });
    }

    Ok(results)
}

