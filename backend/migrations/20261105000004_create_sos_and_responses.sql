-- Migration: 000004_create_sos_and_responses

CREATE TABLE IF NOT EXISTS sos_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_number VARCHAR(32) UNIQUE NOT NULL,
    reporter_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(32) NOT NULL DEFAULT 'OPEN', -- OPEN, RESPONDING, HELP_ARRIVING, ASSISTANCE_PROVIDED, RESOLVED, CANCELLED, EXPIRED
    animal_type VARCHAR(32) NOT NULL, -- DOG, CAT, CATTLE, BIRD, OTHER, UNKNOWN
    emergency_type VARCHAR(32) NOT NULL, -- INJURED, ROAD_ACCIDENT, TRAPPED, ABANDONED, SICK, IN_DANGER, OTHER
    location geography(Point, 4326) NOT NULL,
    accuracy_meters REAL,
    address TEXT NOT NULL,
    landmark TEXT,
    description TEXT,
    primary_responder_id UUID REFERENCES users(id),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sos_location ON sos_requests USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_sos_status ON sos_requests (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sos_reporter ON sos_requests (reporter_id);
CREATE INDEX IF NOT EXISTS idx_sos_primary_responder ON sos_requests (primary_responder_id);

CREATE TABLE IF NOT EXISTS sos_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sos_id UUID NOT NULL REFERENCES sos_requests(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL, -- IMAGE, AUDIO_NOTE, VIDEO
    url TEXT NOT NULL,
    thumbnail_url TEXT,
    caption TEXT,
    duration_seconds INTEGER,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sos_media_sos_id ON sos_media (sos_id);

CREATE TABLE IF NOT EXISTS sos_requirements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sos_id UUID NOT NULL REFERENCES sos_requests(id) ON DELETE CASCADE,
    requirement_type VARCHAR(32) NOT NULL -- FIRST_AID, TRANSPORTATION, PHYSICAL_ASSISTANCE, TEMPORARY_SHELTER, CARRIER, VETERINARY, UNSURE
);

CREATE INDEX IF NOT EXISTS idx_sos_reqs_sos_id ON sos_requirements (sos_id);

CREATE TABLE IF NOT EXISTS sos_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sos_id UUID NOT NULL REFERENCES sos_requests(id) ON DELETE CASCADE,
    responder_id UUID NOT NULL REFERENCES users(id),
    response_role VARCHAR(20) NOT NULL DEFAULT 'PRIMARY', -- PRIMARY, SUPPORTING
    status VARCHAR(32) NOT NULL DEFAULT 'EN_ROUTE', -- EN_ROUTE, ON_SITE, WITHDRAWN, COMPLETED
    eta_minutes INTEGER,
    equipment_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_sos_responder UNIQUE (sos_id, responder_id)
);

CREATE INDEX IF NOT EXISTS idx_sos_responses_sos ON sos_responses (sos_id);
CREATE INDEX IF NOT EXISTS idx_sos_responses_responder ON sos_responses (responder_id);

CREATE TABLE IF NOT EXISTS sos_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sos_id UUID NOT NULL REFERENCES sos_requests(id) ON DELETE CASCADE,
    previous_status VARCHAR(32),
    new_status VARCHAR(32) NOT NULL,
    actor_id UUID NOT NULL REFERENCES users(id),
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sos_history_sos ON sos_status_history (sos_id, created_at ASC);

CREATE TABLE IF NOT EXISTS location_sharing_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sos_id UUID NOT NULL REFERENCES sos_requests(id) ON DELETE CASCADE,
    responder_id UUID NOT NULL REFERENCES users(id),
    current_location geography(Point, 4326) NOT NULL,
    heading REAL,
    speed_kmh REAL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_sos_sharing_responder UNIQUE (sos_id, responder_id)
);

CREATE INDEX IF NOT EXISTS idx_location_sharing_loc ON location_sharing_sessions USING GIST (current_location);

