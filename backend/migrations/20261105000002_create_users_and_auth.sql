-- Migration: 000002_create_users_and_auth

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    role VARCHAR(32) NOT NULL DEFAULT 'REPORTER', -- REPORTER, VOLUNTEER, VET, ADMIN
    preferred_language VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    device_type VARCHAR(20) NOT NULL, -- ANDROID, IOS, WEB
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_device_token UNIQUE (user_id, fcm_token)
);

CREATE TABLE IF NOT EXISTS user_volunteer_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    verification_status VARCHAR(32) NOT NULL DEFAULT 'UNVERIFIED', -- UNVERIFIED, PENDING, VERIFIED
    vehicle_type VARCHAR(32) DEFAULT 'NONE', -- TWO_WHEELER, FOUR_WHEELER, AMBULANCE, NONE
    capabilities TEXT[] NOT NULL DEFAULT '{}', -- FIRST_AID, TRANSPORT, VET_CARE, SHELTER, PHYSICAL_AID
    response_radius_km INTEGER NOT NULL DEFAULT 5,
    last_known_location geography(Point, 4326),
    rescues_completed_count INTEGER NOT NULL DEFAULT 0,
    badge_label VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_volunteer_location ON user_volunteer_profiles USING GIST (last_known_location);
CREATE INDEX IF NOT EXISTS idx_volunteer_availability ON user_volunteer_profiles (is_available, verification_status);

CREATE TABLE IF NOT EXISTS user_notification_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    emergency_alerts BOOLEAN NOT NULL DEFAULT TRUE,
    response_updates BOOLEAN NOT NULL DEFAULT TRUE,
    community_updates BOOLEAN NOT NULL DEFAULT TRUE,
    radius_km INTEGER NOT NULL DEFAULT 5,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

