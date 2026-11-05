use axum::{
    extract::{Path, Query, State},
    routing::get,
    Json, Router,
};
use uuid::Uuid;

use crate::{
    auth::AppState,
    errors::AppError,
    modules::organizations::models::{NearbyOrganizationsQuery, OrganizationItem},
};

pub fn organizations_router() -> Router<AppState> {
    Router::new()
        .route("/", get(list_organizations_handler))
        .route("/nearby", get(list_nearby_organizations_handler))
        .route("/:id", get(get_organization_by_id_handler))
}

pub async fn list_nearby_organizations_handler(
    State(state): State<AppState>,
    Query(query): Query<NearbyOrganizationsQuery>,
) -> Result<Json<Vec<OrganizationItem>>, AppError> {
    let radius_meters = query.radius_km.unwrap_or(25.0) * 1000.0;

    let rows = sqlx::query!(
        r#"
        SELECT 
            id, name, org_type, description, address,
            ST_Y(location::geometry) as latitude,
            ST_X(location::geometry) as longitude,
            ST_Distance(location, ST_SetSRID(ST_MakePoint($1, $2), 4326)) as distance_meters,
            phone, emergency_phone, website, operating_hours, is_24_7, is_verified, facilities,
            created_at
        FROM organizations
        WHERE 
            ST_DWithin(location, ST_SetSRID(ST_MakePoint($1, $2), 4326), $3)
            AND ($4::TEXT IS NULL OR org_type = $4)
            AND ($5::BOOLEAN IS NULL OR is_24_7 = $5)
        ORDER BY distance_meters ASC
        LIMIT 50
        "#,
        query.longitude,
        query.latitude,
        radius_meters,
        query.org_type,
        query.is_24_7
    )
    .fetch_all(&state.pool)
    .await?;

    let items = rows.into_iter().map(|r| OrganizationItem {
        id: r.id,
        name: r.name,
        org_type: r.org_type,
        description: r.description,
        address: r.address,
        latitude: r.latitude.unwrap_or(0.0),
        longitude: r.longitude.unwrap_or(0.0),
        distance_meters: r.distance_meters,
        phone: r.phone,
        emergency_phone: r.emergency_phone,
        website: r.website,
        operating_hours: r.operating_hours,
        is_24_7: r.is_24_7,
        is_verified: r.is_verified,
        facilities: r.facilities,
        created_at: r.created_at,
    }).collect();

    Ok(Json(items))
}

pub async fn list_organizations_handler(
    State(state): State<AppState>,
) -> Result<Json<Vec<OrganizationItem>>, AppError> {
    let rows = sqlx::query!(
        r#"
        SELECT 
            id, name, org_type, description, address,
            ST_Y(location::geometry) as latitude,
            ST_X(location::geometry) as longitude,
            phone, emergency_phone, website, operating_hours, is_24_7, is_verified, facilities,
            created_at
        FROM organizations
        ORDER BY is_24_7 DESC, is_verified DESC, name ASC
        LIMIT 100
        "#
    )
    .fetch_all(&state.pool)
    .await?;

    let items = rows.into_iter().map(|r| OrganizationItem {
        id: r.id,
        name: r.name,
        org_type: r.org_type,
        description: r.description,
        address: r.address,
        latitude: r.latitude.unwrap_or(0.0),
        longitude: r.longitude.unwrap_or(0.0),
        distance_meters: None,
        phone: r.phone,
        emergency_phone: r.emergency_phone,
        website: r.website,
        operating_hours: r.operating_hours,
        is_24_7: r.is_24_7,
        is_verified: r.is_verified,
        facilities: r.facilities,
        created_at: r.created_at,
    }).collect();

    Ok(Json(items))
}

pub async fn get_organization_by_id_handler(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
) -> Result<Json<OrganizationItem>, AppError> {
    let r = sqlx::query!(
        r#"
        SELECT 
            id, name, org_type, description, address,
            ST_Y(location::geometry) as latitude,
            ST_X(location::geometry) as longitude,
            phone, emergency_phone, website, operating_hours, is_24_7, is_verified, facilities,
            created_at
        FROM organizations
        WHERE id = $1
        "#,
        id
    )
    .fetch_optional(&state.pool)
    .await?
    .ok_or_else(|| AppError::NotFound(format!("Organization '{}' not found.", id)))?;

    Ok(Json(OrganizationItem {
        id: r.id,
        name: r.name,
        org_type: r.org_type,
        description: r.description,
        address: r.address,
        latitude: r.latitude.unwrap_or(0.0),
        longitude: r.longitude.unwrap_or(0.0),
        distance_meters: None,
        phone: r.phone,
        emergency_phone: r.emergency_phone,
        website: r.website,
        operating_hours: r.operating_hours,
        is_24_7: r.is_24_7,
        is_verified: r.is_verified,
        facilities: r.facilities,
        created_at: r.created_at,
    }))
}

