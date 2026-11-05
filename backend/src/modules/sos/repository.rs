use chrono::{Duration, Utc};
use rand::Rng;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{
    errors::AppError,
    modules::sos::models::{CreateSosDto, NearbySosQuery, SosDetailResponse, SosMediaItem, SosRequestItem, SosStatusHistoryItem},
};

pub struct SosRepository;

impl SosRepository {
    pub async fn create_sos(
        pool: &PgPool,
        reporter_id: Uuid,
        dto: CreateSosDto,
    ) -> Result<SosRequestItem, AppError> {
        let mut tx = pool.begin().await?;

        // 1. Generate unique case number (e.g. SOS-BLR-8921)
        let random_num: u16 = rand::thread_rng().gen_range(1000..9999);
        let case_number = format!("SOS-BLR-{}", random_num);
        let expires_at = Utc::now() + Duration::hours(24);

        // 2. Insert SOS Request
        let sos_row = sqlx::query!(
            r#"
            INSERT INTO sos_requests (
                case_number, reporter_id, status, animal_type, emergency_type,
                location, accuracy_meters, address, landmark, description, expires_at
            )
            VALUES ($1, $2, 'OPEN', $3, $4, ST_SetSRID(ST_MakePoint($5, $6), 4326), $7, $8, $9, $10, $11)
            RETURNING id, case_number, reporter_id, status, animal_type, emergency_type,
                      ST_Y(location::geometry) as latitude, ST_X(location::geometry) as longitude,
                      accuracy_meters, address, landmark, description, expires_at, created_at, updated_at
            "#,
            case_number,
            reporter_id,
            dto.animal_type.to_uppercase(),
            dto.emergency_type.to_uppercase(),
            dto.longitude,
            dto.latitude,
            dto.accuracy_meters,
            dto.address,
            dto.landmark,
            dto.description,
            expires_at
        )
        .fetch_one(&mut *tx)
        .await?;

        let sos_id = sos_row.id;

        // 3. Insert Media
        let mut media_items = Vec::new();
        for (i, url) in dto.media_urls.iter().enumerate() {
            let media_row = sqlx::query!(
                r#"
                INSERT INTO sos_media (sos_id, media_type, url, thumbnail_url, sort_order)
                VALUES ($1, 'IMAGE', $2, $2, $3)
                RETURNING id, media_type, url, thumbnail_url, caption
                "#,
                sos_id,
                url,
                i as i32
            )
            .fetch_one(&mut *tx)
            .await?;

            media_items.push(SosMediaItem {
                id: media_row.id,
                media_type: media_row.media_type,
                url: media_row.url,
                thumbnail_url: media_row.thumbnail_url,
                caption: media_row.caption,
            });
        }

        // Voice memo if provided
        if let Some(voice_url) = dto.voice_memo_url {
            let voice_row = sqlx::query!(
                r#"
                INSERT INTO sos_media (sos_id, media_type, url, sort_order)
                VALUES ($1, 'AUDIO_NOTE', $2, 99)
                RETURNING id, media_type, url, thumbnail_url, caption
                "#,
                sos_id,
                voice_url
            )
            .fetch_one(&mut *tx)
            .await?;

            media_items.push(SosMediaItem {
                id: voice_row.id,
                media_type: voice_row.media_type,
                url: voice_row.url,
                thumbnail_url: voice_row.thumbnail_url,
                caption: voice_row.caption,
            });
        }

        // 4. Insert Requirements
        for req in &dto.requirements {
            sqlx::query!(
                "INSERT INTO sos_requirements (sos_id, requirement_type) VALUES ($1, $2)",
                sos_id,
                req.to_uppercase()
            )
            .execute(&mut *tx)
            .await?;
        }

        // 5. Insert initial status history
        sqlx::query!(
            r#"
            INSERT INTO sos_status_history (sos_id, previous_status, new_status, actor_id, reason)
            VALUES ($1, NULL, 'OPEN', $2, 'Emergency alert filed with photo and pinpoint telemetry.')
            "#,
            sos_id,
            reporter_id
        )
        .execute(&mut *tx)
        .await?;

        // 6. Enqueue notifications in outbox for nearby eligible volunteers
        let nearby_volunteers = sqlx::query!(
            r#"
            SELECT u.id as user_id
            FROM user_volunteer_profiles p
            JOIN users u ON p.user_id = u.id
            WHERE p.is_available = TRUE
              AND p.user_id != $1
              AND p.last_known_location IS NOT NULL
              AND ST_DWithin(p.last_known_location, ST_SetSRID(ST_MakePoint($2, $3), 4326), (p.response_radius_km * 1000)::double precision)
            LIMIT 50
            "#,
            reporter_id,
            dto.longitude,
            dto.latitude
        )
        .fetch_all(&mut *tx)
        .await?;

        let notif_payload = serde_json::json!({
            "sos_id": sos_id,
            "case_number": case_number,
            "animal_type": dto.animal_type,
            "emergency_type": dto.emergency_type,
            "address": dto.address,
        });

        for volunteer in nearby_volunteers {
            sqlx::query!(
                r#"
                INSERT INTO notification_outbox (event_type, recipient_user_id, sos_id, title, body, payload_json)
                VALUES ('SOS_CREATED', $1, $2, '🚨 Urgent Animal SOS Nearby', $3, $4)
                "#,
                volunteer.user_id,
                sos_id,
                format!("A {} is in distress near {}. Can you assist?", dto.animal_type, dto.address),
                notif_payload
            )
            .execute(&mut *tx)
            .await?;
        }

        tx.commit().await?;

        // Fetch reporter name
        let reporter = sqlx::query!("SELECT name FROM users WHERE id = $1", reporter_id)
            .fetch_optional(pool)
            .await?
            .map(|r| r.name);

        Ok(SosRequestItem {
            id: sos_id,
            case_number,
            reporter_id,
            reporter_name: reporter,
            status: "OPEN".to_string(),
            animal_type: dto.animal_type,
            emergency_type: dto.emergency_type,
            latitude: dto.latitude,
            longitude: dto.longitude,
            distance_meters: Some(0.0),
            accuracy_meters: dto.accuracy_meters,
            address: dto.address,
            landmark: dto.landmark,
            description: dto.description,
            primary_responder_id: None,
            primary_responder_name: None,
            primary_responder_phone: None,
            primary_responder_avatar: None,
            primary_responder_eta_minutes: None,
            media: media_items,
            requirements: dto.requirements,
            created_at: sos_row.created_at,
            updated_at: sos_row.updated_at,
        })
    }

    pub async fn get_sos_by_id(pool: &PgPool, sos_id: Uuid) -> Result<SosDetailResponse, AppError> {
        let row = sqlx::query!(
            r#"
            SELECT 
                s.id, s.case_number, s.reporter_id, u.name as reporter_name,
                s.status, s.animal_type, s.emergency_type,
                ST_Y(s.location::geometry) as latitude,
                ST_X(s.location::geometry) as longitude,
                s.accuracy_meters, s.address, s.landmark, s.description,
                s.primary_responder_id, r.name as primary_responder_name,
                r.phone as primary_responder_phone, r.avatar_url as primary_responder_avatar,
                res.eta_minutes as primary_responder_eta_minutes,
                s.created_at, s.updated_at
            FROM sos_requests s
            LEFT JOIN users u ON s.reporter_id = u.id
            LEFT JOIN users r ON s.primary_responder_id = r.id
            LEFT JOIN sos_responses res ON s.id = res.sos_id AND s.primary_responder_id = res.responder_id
            WHERE s.id = $1
            "#,
            sos_id
        )
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound(format!("SOS request '{}' not found.", sos_id)))?;

        let media_rows = sqlx::query!(
            "SELECT id, media_type, url, thumbnail_url, caption FROM sos_media WHERE sos_id = $1 ORDER BY sort_order ASC",
            sos_id
        )
        .fetch_all(pool)
        .await?;

        let media = media_rows.into_iter().map(|m| SosMediaItem {
            id: m.id,
            media_type: m.media_type,
            url: m.url,
            thumbnail_url: m.thumbnail_url,
            caption: m.caption,
        }).collect();

        let req_rows = sqlx::query!(
            "SELECT requirement_type FROM sos_requirements WHERE sos_id = $1",
            sos_id
        )
        .fetch_all(pool)
        .await?;

        let requirements = req_rows.into_iter().map(|r| r.requirement_type).collect();

        let history_rows = sqlx::query!(
            r#"
            SELECT h.id, h.previous_status, h.new_status, h.actor_id, u.name as actor_name, h.reason, h.created_at
            FROM sos_status_history h
            LEFT JOIN users u ON h.actor_id = u.id
            WHERE h.sos_id = $1
            ORDER BY h.created_at ASC
            "#,
            sos_id
        )
        .fetch_all(pool)
        .await?;

        let status_history = history_rows.into_iter().map(|h| SosStatusHistoryItem {
            id: h.id,
            previous_status: h.previous_status,
            new_status: h.new_status,
            actor_id: h.actor_id,
            actor_name: h.actor_name,
            reason: h.reason,
            created_at: h.created_at,
        }).collect();

        let active_responders_count = sqlx::query_scalar!(
            "SELECT COUNT(*) FROM sos_responses WHERE sos_id = $1 AND status != 'WITHDRAWN'",
            sos_id
        )
        .fetch_one(pool)
        .await?
        .unwrap_or(0);

        Ok(SosDetailResponse {
            sos: SosRequestItem {
                id: row.id,
                case_number: row.case_number,
                reporter_id: row.reporter_id,
                reporter_name: row.reporter_name,
                status: row.status,
                animal_type: row.animal_type,
                emergency_type: row.emergency_type,
                latitude: row.latitude.unwrap_or(0.0),
                longitude: row.longitude.unwrap_or(0.0),
                distance_meters: None,
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
            },
            status_history,
            active_responders_count,
        })
    }

    pub async fn list_nearby(
        pool: &PgPool,
        query: NearbySosQuery,
    ) -> Result<Vec<SosRequestItem>, AppError> {
        let radius_meters = query.radius_km.unwrap_or(10.0) * 1000.0;

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
                ($3::TEXT IS NULL OR s.status = $3)
                AND ($4::TEXT IS NULL OR s.animal_type = $4)
                AND ST_DWithin(s.location, ST_SetSRID(ST_MakePoint($1, $2), 4326), $5)
            ORDER BY distance_meters ASC
            LIMIT 50
            "#,
            query.longitude,
            query.latitude,
            query.status,
            query.animal_type,
            radius_meters
        )
        .fetch_all(pool)
        .await?;

        let mut items = Vec::new();
        for row in rows {
            let media_rows = sqlx::query!(
                "SELECT id, media_type, url, thumbnail_url, caption FROM sos_media WHERE sos_id = $1 ORDER BY sort_order ASC",
                row.id
            )
            .fetch_all(pool)
            .await?;

            let media = media_rows.into_iter().map(|m| SosMediaItem {
                id: m.id,
                media_type: m.media_type,
                url: m.url,
                thumbnail_url: m.thumbnail_url,
                caption: m.caption,
            }).collect();

            let req_rows = sqlx::query!(
                "SELECT requirement_type FROM sos_requirements WHERE sos_id = $1",
                row.id
            )
            .fetch_all(pool)
            .await?;

            let requirements = req_rows.into_iter().map(|r| r.requirement_type).collect();

            items.push(SosRequestItem {
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

        Ok(items)
    }
}

